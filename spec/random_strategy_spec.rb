require File.expand_path("../spec_helper", __FILE__)

module Danger
  describe Danger::AssignStrategies::RandomStrategy do
    before do
      testing_env.each { |k,v| ENV[k] = "#{v}" }
      @dangerfile = testing_dangerfile

      @mock_client = double(Gitlab::Client)
      @author = Gitlab::User.new(1, 'Nic')
      @members = [@author, Gitlab::User.new(2, 'Tom'), Gitlab::User.new(3, 'Sam')]
      allow(@mock_client).to receive(:fetch_author_for_mr).and_return(@author)
      allow(@mock_client).to receive(:fetch_users_for_group).with(2200).and_return(@members)

      @strategy = AssignStrategies::RandomStrategy.new(client: @mock_client, project: 10, mr: 110, group: 2200)
    end

    it "Assign the right amount of reviewers" do
      expect(@mock_client).to receive(:assign_mr_to_users) do |project, mr, users|
        expect(project).to be == 10
        expect(mr).to be == 110
        expect(users).target.count eq 2
      end

      @strategy.assign!(2)
    end

    it "Doesn't assign author" do
      expect(@mock_client).to receive(:assign_mr_to_users) do |project, mr, users|
        expect(project).to be == 10
        expect(mr).to be == 110
        expect(users).target.count eq 2
      end

      @strategy.assign!(3)
    end

  end
end

