# frozen_string_literal: true

module Bookbind
  # Pandoc 3.0 introduced --split-level, which the EPUB writer relies on.
  class PandocRequirement
    MINIMUM = Gem::Version.new("3.0")
    HINT = "Install pandoc 3.0 or newer: 'brew install pandoc' (macOS), " \
           "'sudo apt install pandoc' (Debian/Ubuntu), or see https://pandoc.org/installing.html"

    def check(runner)
      version = parse(runner.run("pandoc", "--version"))
      raise MissingToolError, "pandoc not found. #{HINT}" unless version
      raise MissingToolError, "pandoc #{version} is too old. #{HINT}" if version < MINIMUM
    end

    private

    def parse(result)
      number = result.stdout[/\Apandoc(?:\.exe)? (\d+(?:\.\d+)*)/, 1] if result.success?
      Gem::Version.new(number) if number
    end
  end
end
