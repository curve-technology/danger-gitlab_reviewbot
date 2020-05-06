require 'gitlab_reviewbot/gitlab'

module Danger
  module AssignStrategies
    class LeastBusyStrategy < Strategy
      def assignees(amount)
        review_counter = client.fetch_users_for_group(group_name).reduce({}) do |counter, user|
          counter[user.id] = user
          counter
        end

        users = client.users_with_pending_mr_review(project_id) do |counter, user|
          next if counter[user.id].nil?
          counter[user.id].review_count += 1
          counter
        end
        users.filter { |u| u.id != author.id }
             .sort_by(&:review_count)
             .last(amount)
      end
    end
  end
end

