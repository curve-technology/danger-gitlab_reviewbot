module Danger
  module AssignStrategies
    class Strategy
      attr_accessor :mr_iid
      attr_accessor :project_id
      attr_accessor :group_name
      attr_accessor :client

      def initialize(client:, project:, mr:, group:)
        @client = client
        @project_id = project
        @mr_iid = mr
        @group_name = group
      end

      def assign!(amount)
        to_be_assigned = assignees(amount)
        response = client.assign_mr_to_users(project_id, mr_iid, to_be_assigned)
        return to_be_assigned.map(&:username)
      end

      def assignees(amount)
        raise "To be implemented in the subclasses"
      end

      def author
        client.fetch_author_for_mr(@project_id, @mr_iid)
      end

      def users_in_group
        client.fetch_users_for_group(group_name)
      end
    end
  end
end

