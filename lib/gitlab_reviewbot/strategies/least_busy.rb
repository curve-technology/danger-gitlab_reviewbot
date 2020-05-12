require 'gitlab_reviewbot/gitlab'

module Danger
  module AssignStrategies
    class LeastBusyStrategy < Strategy
      def assignees(amount)
        users_in_group = fetch_users_in_group()
        author = fetch_author()
        invalid_assignees = [ fetch_author() ] + fetch_assigned_reviewers()

        users_with_reviews_pending = client.users_with_pending_mr_review(project_id)
        users_without_reviews_pending = users_in_group.filter { |u| ! users_with_reviews_pending.include? u }

        (users_with_reviews_pending + users_without_reviews_pending).filter { |u| u.id != author.id }
                                                                    .sort_by(&:review_count)
                                                                    .first(amount)
      end
    end
  end
end

