# frozen_string_literal: true

module Bookbind
  # A tool that only has to be present: it must answer `COMMAND --version`.
  class ExecutableRequirement
    def initialize(command:, hint:)
      @command = command
      @hint = hint
    end

    def check(runner)
      raise MissingToolError, "#{@command} not found. #{@hint}" unless runner.run(@command, "--version").success?
    end
  end
end
