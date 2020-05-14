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
        @strategy_mock = instance_double(Danger::AssignStrategies::Strategy)
        allow(Danger::AssignStrategies::RandomStrategy).to receive(:new).and_return(@strategy_mock)
        allow(@strategy_mock).to receive(:group_name=).with('tech/ios')
        @plugin.strategy = Danger::AssignStrategies::RandomStrategy
        @plugin.gitlab_group = 'tech/ios'

      end

      it "Assign one reviewer" do
        expect(@strategy_mock).to receive(:assign!).with(1).and_return(['Sam'])

        @plugin.assign!
      end
      it "Assign one reviewer" do
        expect(@strategy_mock).to receive(:assign!).with(1).and_return(['Sam'])

        @plugin.assign!
      end

      it "Assign multiple reviewers" do
        @plugin.assignees_amount = 2

        expect(@strategy_mock).to receive(:assign!).with(2).and_return(['Sam, Nic'])

        @plugin.assign!
      end

      it "Correctly sets strategy options" do
        expect(@strategy_mock).to receive(:excluded_users=)
        expect(@strategy_mock).to receive(:excluded_users).and_return([])

        @plugin.strategy_excluded_users = ['Tom']
        @plugin.strategy_excluded_users << 'Sam'

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

