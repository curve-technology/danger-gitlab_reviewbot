module Danger
  module AssignStrategies
    class Strategy
      attr_accessor :mr_iid
      attr_accessor :project_id
      attr_accessor :group_name
      attr_accessor :client
      attr_accessor :excluded_users

      def initialize(client:, project:, mr:)
        @client = client
        @project_id = project
        @mr_iid = mr
        @excluded_users = []
      end

      def assign!(amount)
        currently_assigned = fetch_assigned_reviewers()
        return [] if (amount - currently_assigned.length) <= 0

        to_be_assigned = assignees(amount - currently_assigned.length)
        all_assignees = currently_assigned + to_be_assigned

        response = client.assign_mr_to_users(project_id, mr_iid, all_assignees)
        all_assignees.map(&:username)
      end

      def assignees(amount)
        raise "To be implemented in the subclasses"
      end

      def fetch_author
        client.fetch_author_for_mr(@project_id, @mr_iid)
      end

      def fetch_assigned_reviewers
        client.fetch_mr_reviewers(@project_id, @mr_iid)
      end

      def fetch_users_in_group
        excluded = @excluded_users.map { |u| client.find_user_with_username(u) }
        client.fetch_users_for_group(@group_name).filter { |u| ! excluded.include? u }
      end

    end
  end
end

