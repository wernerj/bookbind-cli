# frozen_string_literal: true

module Bookbind
  # Runs an external program from an argument array. The [cmd, cmd] form guarantees no shell is involved.
  class CommandRunner
    def run(command, *)
      stdout, stderr, status = Open3.capture3([command, command], *)
      CommandResult.new(stdout:, stderr:, success: status.success?)
    rescue SystemCallError => e
      CommandResult.new(stdout: "", stderr: e.message, success: false)
    end
  end
end
