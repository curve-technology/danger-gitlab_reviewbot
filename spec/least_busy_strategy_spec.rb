require File.expand_path("../spec_helper", __FILE__)

module Danger
  describe Danger::AssignStrategies::LeastBusyStrategy do
    before do
      testing_env.each { |k,v| ENV[k] = "#{v}" }
      @dangerfile = testing_dangerfile

      @sam = Gitlab::User.new(1, 'Sam')
      @tom = Gitlab::User.new(2, 'Tom')
      @nic = Gitlab::User.new(3, 'Nic')
      @luke = Gitlab::User.new(4, 'Luke')

      @mock_client = double(Gitlab::Client)
      @author = @nic
      @nic.review_count = 0
      @members = [@author, @tom, @sam, @luke]
      allow(@mock_client).to receive(:fetch_author_for_mr).and_return(@author)
      allow(@mock_client).to receive(:fetch_users_for_group).with(2200).and_return(@members)

      @strategy = AssignStrategies::LeastBusyStrategy.new(client: @mock_client, project: 10, mr: 110, group: 2200)
    end

    it "Assign the one least busy" do
      allow(@mock_client).to receive(:fetch_mr_reviewers).with(10, 110).and_return([])
      @tom.review_count = 1
      @sam.review_count = 4
      @luke.review_count = 3
      users_with_pending_mr_review = [@author, @sam, @tom]
      expect(@mock_client).to receive(:users_with_pending_mr_review).and_return(users_with_pending_mr_review)

      expect(@mock_client).to receive(:assign_mr_to_users) do |project, mr, users|
        expect(project).to be == 10
        expect(mr).to be == 110
        expect(users).to contain_exactly(@tom)
      end

      @strategy.assign!(1)
    end

    it "Assign the one with no review pending first (least busy)" do
      allow(@mock_client).to receive(:fetch_mr_reviewers).with(10, 110).and_return([])
      @tom.review_count = 1
      @sam.review_count = 4
      @luke.review_count = 0

      users_with_pending_mr_review = [@author, @sam, @tom]
      expect(@mock_client).to receive(:users_with_pending_mr_review).and_return(users_with_pending_mr_review)

      expect(@mock_client).to receive(:assign_mr_to_users) do |project, mr, users|
        expect(project).to be == 10
        expect(mr).to be == 110
        expect(users).to contain_exactly(@luke)
      end

      @strategy.assign!(1)
    end

    it "Honour existing reviewers" do
      allow(@mock_client).to receive(:fetch_mr_reviewers).with(10, 110).and_return([@sam])
      @tom.review_count = 1
      @sam.review_count = 2
      @nic.review_count = 5
      @luke.review_count = 3
      users_with_pending_mr_review = [@author, @sam, @tom, @nic]
      expect(@mock_client).to receive(:users_with_pending_mr_review).and_return(users_with_pending_mr_review)

      expect(@mock_client).to receive(:assign_mr_to_users) do |project, mr, users|
        expect(project).to be == 10
        expect(mr).to be == 110
        expect(users).to contain_exactly(@sam, @tom)
      end

      @strategy.assign!(2)
    end

    it "Assign the one least busy (if two are available)" do
      allow(@mock_client).to receive(:fetch_mr_reviewers).with(10, 110).and_return([])
      @sam.review_count = 1
      @tom.review_count = 1
      users_with_pending_mr_review = [@author, @sam, @tom]
      expect(@mock_client).to receive(:users_with_pending_mr_review).and_return(users_with_pending_mr_review)

      expect(@mock_client).to receive(:assign_mr_to_users) do |project, mr, users|
        expect(project).to be == 10
        expect(mr).to be == 110
        expect(users).target.length == 1
      end

      @strategy.assign!(1)
    end
  end
end

