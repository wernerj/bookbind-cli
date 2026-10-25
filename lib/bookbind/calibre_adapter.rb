# frozen_string_literal: true

module Bookbind
  # Runs Calibre's ebook-convert.
  class CalibreAdapter
    COMMAND = "ebook-convert"
    HINT = "Install Calibre and put ebook-convert on your PATH: 'brew install --cask calibre' " \
           "(macOS, then add /Applications/calibre.app/Contents/MacOS to PATH), " \
           "'sudo apt install calibre' (Debian/Ubuntu), or see https://calibre-ebook.com/download"

    def initialize(runner:)
      @runner = runner
    end

    def requirement = ExecutableRequirement.new(command: COMMAND, hint: HINT)

    def convert(epub, mobi)
      result = @runner.run(COMMAND, epub, mobi)
      raise ConversionError, "#{COMMAND} failed:\n#{tail(result)}" unless result.success?
    end

    private

    # Calibre is chatty; the last lines carry the actual error.
    def tail(result) = (result.stdout.lines.last(3) + result.stderr.lines).map(&:chomp).join("\n").strip
  end
end
