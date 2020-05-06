require File.expand_path("../spec_helper", __FILE__)

module Danger
  describe Danger::DangerGitlabReviewbot do
    it "should be a plugin" do
      expect(Danger::DangerGitlabReviewbot.new(nil)).to be_a Danger::Plugin
    end

    #
    # You should test your custom attributes and methods here
    #
    describe "with Dangerfile" do
      before do
        testing_env.each { |k,v| ENV[k] = "#{v}" }

        @dangerfile = testing_dangerfile
        @plugin = @dangerfile.gitlab_reviewbot
        @plugin.strategy = Danger::AssignStrategies::RandomStrategy
        @strategy_mock = instance_double(Danger::AssignStrategies::Strategy)
        allow(Danger::AssignStrategies::RandomStrategy).to receive(:new).and_return(@strategy_mock)
      end

      it "Assign one reviewer" do
        @plugin.gitlab_group = 'tech/ios'

        expect(@strategy_mock).to receive(:assign!).with(1).and_return(['Sam'])

        @plugin.assign!
      end
      it "Assign one reviewer" do
        @plugin.gitlab_group = 'tech/ios'

        expect(@strategy_mock).to receive(:assign!).with(1).and_return(['Sam'])

        @plugin.assign!
      end

      it "Assign multiple reviewers" do
        @plugin.gitlab_group = 'tech/ios'
        @plugin.assignees_amount = 2

        expect(@strategy_mock).to receive(:assign!).with(2).and_return(['Sam, Nic'])

        @plugin.assign!
      end

      it "Doesn't assign if already asssigned" do
        ENV['CI_MERGE_REQUEST_ASSIGNEES'] = 'Sam'
        @plugin.gitlab_group = 'tech/ios'

        expect(@strategy_mock).not_to receive(:assign!)

        @plugin.assign!
      end

      it "Only assigns delta" do
        ENV['CI_MERGE_REQUEST_ASSIGNEES'] = 'Sam,Nic'
        @plugin.gitlab_group = 'tech/ios'
        @plugin.assignees_amount = 3

        expect(@strategy_mock).to receive(:assign!).with(1).and_return(['Rob'])

        @plugin.assign!
      end

      ['CI_PROJECT_ID', 'CI_MERGE_REQUEST_IID'].each do |var|
        it "Fails when required #{var} variables are not available" do
          ENV[var] = nil
          expect{@plugin.assign!}.to raise_error(RuntimeError)
        end
      end
    end
  end
end

