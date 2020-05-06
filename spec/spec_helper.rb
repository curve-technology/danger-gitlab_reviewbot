require "pathname"
ROOT = Pathname.new(File.expand_path("../../", __FILE__))
$:.unshift((ROOT + "lib").to_s)
$:.unshift((ROOT + "spec").to_s)

require "bundler/setup"
require "pry"

require "rspec"
require "danger"

if `git remote -v` == ''
  puts "You cannot run tests without setting a local git remote on this repo"
  puts "It's a weird side-effect of Danger's internals."
  exit(0)
end

# Use coloured output, it's the best.
RSpec.configure do |config|
  config.filter_gems_from_backtrace "bundler"
  config.color = true
  config.tty = true
end

require "danger_plugin"

# These functions are a subset of https://github.com/danger/danger/blob/master/spec/spec_helper.rb
# If you are expanding these files, see if it's already been done ^.

# A silent version of the user interface,
# it comes with an extra function `.string` which will
# strip all ANSI colours from the string.

# rubocop:disable Lint/NestedMethodDefinition
def testing_ui
  @output = StringIO.new
  def @output.winsize
    [20, 9999]
  end

  cork = Cork::Board.new(out: @output)
  def cork.string
    out.string.gsub(/\e\[([;\d]+)?m/, "")
  end
  cork
end
# rubocop:enable Lint/NestedMethodDefinition

# Example environment (ENV) that would come from
# running a PR on TravisCI
def testing_env
  {
    'CI_MERGE_REQUEST_IID' => '549',
    'CI_MERGE_REQUEST_PROJECT_PATH' => '...',
    'CI_MERGE_REQUEST_PROJECT_URL' => '...',
    'DANGER_GITLAB_HOST' => 'github.com', # This needs to be the same as where the repo is stored due to Danger internals :facepalm:
    'CI_API_V4_URL' => "https://gitlab.com/api/v4",
    'CI_PROJECT_ID' => '346',
    "GITLAB_CI" => true,
    "DANGER_GITLAB_API_TOKEN" => "token-token-token"
  }
end

# A stubbed out Dangerfile for use in tests
def testing_dangerfile
  env = Danger::EnvironmentManager.new(testing_env)
  Danger::Dangerfile.new(env, testing_ui)
end
