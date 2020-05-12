require 'gitlab_reviewbot/gitlab'

module Danger
  module AssignStrategies
    class RandomStrategy < Strategy
      def assignees(amount)
        invalid_assignees = [ fetch_author() ] + fetch_assigned_reviewers()
        fetch_users_in_group.filter { |u| ! invalid_assignees.include? u }
                            .sample(amount)
      end
    end
  end
end
