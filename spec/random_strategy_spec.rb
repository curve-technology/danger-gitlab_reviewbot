require File.expand_path("../spec_helper", __FILE__)

module Danger
  describe Danger::AssignStrategies::RandomStrategy do
    before do
      testing_env.each { |k,v| ENV[k] = "#{v}" }
      @dangerfile = testing_dangerfile

      @sam = Gitlab::User.new(1, 'Sam')
      @tom = Gitlab::User.new(2, 'Tom')
      @nic = Gitlab::User.new(3, 'Nic')
      @luke = Gitlab::User.new(4, 'Luke')
      @lei = Gitlab::User.new(5, 'Lei')


      @mock_client = double(Gitlab::Client)
      @author = @lei
      @members = [@author, @tom, @sam]
      allow(@mock_client).to receive(:fetch_author_for_mr).and_return(@author)
      allow(@mock_client).to receive(:fetch_users_for_group).with("tech/ios").and_return(@members)

      @strategy = AssignStrategies::RandomStrategy.new(client: @mock_client, project: 10, mr: 110)
      @strategy.group_name = "tech/ios"
    end

    it "assign the right amount of reviewers" do
      allow(@mock_client).to receive(:fetch_mr_reviewers).with(10, 110).and_return([])
      expect(@mock_client).to receive(:assign_mr_to_users) do |project, mr, users|
        expect(project).to be == 10
        expect(mr).to be == 110
        expect(users).to contain_exactly(@tom, @sam)
      end

      @strategy.assign!(2)
    end

    it "doesn't assign author" do
      allow(@mock_client).to receive(:fetch_mr_reviewers).with(10, 110).and_return([])

      expect(@mock_client).to receive(:assign_mr_to_users) do |project, mr, users|
        expect(project).to be == 10
        expect(mr).to be == 110
        expect(users).to contain_exactly(@tom, @sam)
      end

      @strategy.assign!(3)
    end

    it "honours existing reviewers" do
      allow(@mock_client).to receive(:fetch_mr_reviewers).with(10, 110).and_return([@sam])
      expect(@mock_client).to receive(:assign_mr_to_users) do |project, mr, users|
        expect(project).to be == 10
        expect(mr).to be == 110
        expect(users).to contain_exactly(@tom, @sam)
      end

      @strategy.assign!(2)
    end

  end
end

