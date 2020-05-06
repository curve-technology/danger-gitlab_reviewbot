require 'gitlab_reviewbot/gitlab'

module Danger
  module AssignStrategies
    class RandomStrategy < Strategy
      def assignees(amount)
        client.fetch_users_for_group(group_name)
              .filter { |u| u.id != author.id }
              .sample(amount)
      end
    end
  end
end
