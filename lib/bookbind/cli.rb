# frozen_string_literal: true

module Bookbind
  # Entry point: parse, convert, and turn expected errors into messages and exit codes.
  class CLI
    def initialize(stdout:, stderr:, wiring: Wiring)
      @stdout = stdout
      @stderr = stderr
      @wiring = wiring
    end

    def run(argv)
      options = parser.parse(argv)
      options.help ? help : convert(options)
    rescue Error => e
      @stderr.puts(["bookbind: #{e.message}", e.hint].compact)
      e.exit_code
    end

    private

    def parser = @parser ||= OptionsParser.new(formats: WRITERS.keys)

    def help
      @stdout.puts parser.usage
      0
    end

    def convert(options)
      wiring = @wiring.new(options, stderr: @stderr)
      wiring.conversion.call(options, wiring.output)
      @stdout.puts "Wrote #{wiring.output}"
      0
    end
  end
end
