require File.expand_path("../spec_helper", __FILE__)

module Danger
  describe Danger::AssignStrategies::RandomStrategy do
    before do
      testing_env.each { |k,v| ENV[k] = "#{v}" }
      @dangerfile = testing_dangerfile

      @mock_client = double(Gitlab::Client)
      @author = Gitlab::User.new(1, 'Nic', 0)
      @members = [@author, Gitlab::User.new(2, 'Tom'), Gitlab::User.new(3, 'Sam')]
      allow(@mock_client).to receive(:fetch_author_for_mr).and_return(@author)
      allow(@mock_client).to receive(:fetch_users_for_group).with(2200).and_return(@members)

      @strategy = AssignStrategies::LeastBusyStrategy.new(client: @mock_client, project: 10, mr: 110, group: 2200)
    end

    it "Assign the one least busy" do
      users_with_pending_mr_review = [@author, Gitlab::User.new(2, 'Tom', 1), Gitlab::User.new(3, 'Sam',2)]
      expect(@mock_client).to receive(:users_with_pending_mr_review).and_return(users_with_pending_mr_review)

      expect(@mock_client).to receive(:assign_mr_to_users) do |project, mr, users|
        expect(project).to be == 10
        expect(mr).to be == 110
        expect(users).target.count eq 1
        expect(users).target[0].username == 'Tom'
      end

      @strategy.assign!(1)
    end

    it "Assign the one least busy (if two are available)" do
      users_with_pending_mr_review = [@author, Gitlab::User.new(2, 'Tom', 1), Gitlab::User.new(3, 'Sam',1)]
      expect(@mock_client).to receive(:users_with_pending_mr_review).and_return(users_with_pending_mr_review)

      expect(@mock_client).to receive(:assign_mr_to_users) do |project, mr, users|
        expect(project).to be == 10
        expect(mr).to be == 110
        expect(users).target.count eq 1
        expect(users).target[0].username == 'Tom'
      end

      @strategy.assign!(1)
    end
  end
end

