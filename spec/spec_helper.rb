# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require_relative "../lib/bookbind"
Dir[File.join(__dir__, "support", "*.rb")].each { |file| require file }

FIXTURES = File.expand_path("fixtures", __dir__)

def fixture(name) = File.join(FIXTURES, name)

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.include_chain_clauses_in_custom_matcher_descriptions = true }
  config.mock_with(:rspec) { |m| m.verify_partial_doubles = true }
  config.disable_monkey_patching!
  config.order = :random

  { requires_pandoc: "pandoc", requires_calibre: "ebook-convert" }.each do |tag, command|
    config.before(:each, tag) { skip "#{command} is not installed" unless ToolAvailability.on_path?(command) }
  end
end
