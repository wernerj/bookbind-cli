# frozen_string_literal: true

require "open3"

# Runs bin/bookbind as a subprocess, as a user would.
module BookbindRunner
  BIN = File.expand_path("../../bin/bookbind", __dir__)

  Run = Data.define(:stdout, :stderr, :exit_code)

  def bookbind(*, env: {})
    stdout, stderr, status = Open3.capture3(env, RbConfig.ruby, BIN, *)
    Run.new(stdout:, stderr:, exit_code: status.exitstatus)
  end
end

RSpec.configure { |config| config.include BookbindRunner }
