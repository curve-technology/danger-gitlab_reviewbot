require 'gitlab_reviewbot/strategies'


module Danger
  # This is your plugin class. Any attributes or methods you expose here will
  # be available from within your Dangerfile.
  #
  # To be published on the Danger plugins site, you will need to have
  # the public interface documented. Danger uses [YARD](http://yardoc.org/)
  # for generating documentation from your plugin source, and you can verify
  # by running `danger plugins lint` or `bundle exec rake spec`.
  #
  # You should replace these comments with a public description of your library.
  #
  # @example Ensure people are well warned about merging on Mondays
  #
  #          my_plugin.warn_on_mondays
  #
  # @see  Fabio Gallonetto/danger-gitlab_reviewbot
  # @tags monday, weekends, time, rattata
  #
  class DangerGitlabReviewbot < Plugin

    # Define the group to take the reviewers from. 
    # NOTE: This is the group full path as in 'tech/iOS' instead of just the group name
    #
    # @return   String
    attr_accessor :gitlab_group

    # Define the amount of reviewers to add to the merge requests.
    # Default is 1.
    # NOTE: The plugin won't remove existing assigned reviewers
    #
    # @return   Int
    attr_accessor :assignees_amount
    def assignees_amount
      @assignees_amount || 1
    end

    # Define the strategy for chosing reviewers.
    # Valid values are:
    # * Danger::AssignStrategies::RandomStrategy - assigns N reviewers at random from the group
    #   (excluding the author).
    # * Danger::AssignStrategies::LeastBusyStrategy - assign the N users with the least amount of open MRs
    #   to review
    #
    attr_accessor :strategy
    def strategy
      @strategy || Danger::AssignStrategies::RandomStrategy
    end

    # Call this method from the Dangerfile to assign reviewers to your merge requests
    # @return   The usernames list of assigned reviewes [Array<String>]
    #
    def assign!
      project_id = ENV['CI_PROJECT_ID']
      mr_iid = ENV['CI_MERGE_REQUEST_IID']
      if mr_iid.nil?
        raise "Env variable CI_MERGE_REQUEST_IID doesn't point to a valid merge request iid"
      end

      if project_id.nil?
        raise "Env variable CI_PROJECT_ID doesn't point to a valid project id"
      end

      current_assignees = (ENV['CI_MERGE_REQUEST_ASSIGNEES'] || '').split(',') #buggy?
      already_assigned_count = current_assignees.length
      required_assignees_count = [assignees_amount - already_assigned_count, 0].max

      puts "Project ID: #{project_id}" if verbose
      puts "MR IID: #{mr_iid}" if verbose
      puts "Currently assigned: #{current_assignees}" if verbose
 #    puts "Required: #{required_assignees_count}" if @verbose

      # if required_assignees_count == 0
      #   puts "Nothing to do" if @verbose
      #   return
      # end

      strategy_class = strategy.new(client: gitlab.api, project: project_id, mr: mr_iid, group: gitlab_group)

      assignees = strategy_class.assign! assignees_amount

      puts "Assigning: #{assignees}" if verbose
      return assignees
    end
  end
end

