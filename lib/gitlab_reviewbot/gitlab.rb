require 'gitlab'

module Gitlab
  class User
    attr_accessor :username
    attr_accessor :id
    attr_accessor :review_count

    def initialize(id, username, review_count = 0)
      @id = id
      @username = username
      @review_count = review_count
    end

    def ==(other)
      id == other.id
    end
  end

  class Client < API
    def fetch_users_for_group(group_name)
      group_id = search_group(group_name)
      return nil if group_id.nil?

      res = group_members(group_id)

      developer_access_level = 30
      res.select { |u| u.state == 'active' && u.access_level >= developer_access_level }.map { |u| User.new(u.id, u.username) }
    end

    def assign_mr_to_users(project_id, mr_iid, users)
      user_ids = users.map(&:id)
      update_merge_request(project_id, mr_iid, 'assignee_ids' => user_ids)
    end

    def fetch_author_for_mr(project_id, mr_iid)
      res = merge_request(project_id, mr_iid)
      User.new(res.author.id, res.author.name)
    end

    def fetch_mrs_requiring_review(project_id)
      merge_requests(project_id, :state => 'opened', :per_page => '100').select { |mr| mr.merge_status != 'can_be_merged' }
    end

    def find_user_with_username(username)
      users({:username => username}).map { |u| User.new(u.id, u.username) }
    end

    def users_with_pending_mr_review(project_id)
      outstanding_mrs = fetch_mrs_requiring_review(project_id)
      all_assignees = outstanding_mrs.reduce([]) { |acc, mr| acc + mr.assignees }
      assignees_id_map = all_assignees.reduce({}) { |acc, a|
        aid = a['id']
        ausername = a['username']
        assignee = acc[aid] || User.new(aid, ausername)
        assignee.review_count += 1
        acc[aid] = assignee
        acc
      }
      assignees_id_map.values
    end

    def fetch_mr_reviewers(project_id, mr_iid)
      merge_request(project_id, mr_iid).assignees.map { |u| User.new(u['id'], u['username']) }
    end

    private
    def search_group(group_name)
      short_name = group_name.split('/').last
      res = group_search(short_name)
      res = res.find { |i| i.full_path == group_name }

      if res.nil?
        nil
      else
        res.id
      end
    end
  end
end

