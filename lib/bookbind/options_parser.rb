# frozen_string_literal: true

module Bookbind
  # Turns ARGV into Options, raising UsageError for anything a user could get wrong.
  class OptionsParser
    DEFAULTS = { target: nil, output: nil, title: nil, author: nil, language: "en",
                 stylesheets: [].freeze, strict: false, help: false }.freeze

    STORE = {
      value: ->(values, key, value) { values[key] = value },
      list: ->(values, key, value) { values[key] += [value] },
      flag: ->(values, key, _value) { values[key] = true }
    }.freeze

    SWITCHES = [
      [:target, :value, "-t", "--to FORMAT", "Output format (required)"],
      [:output, :value, "-o", "--output PATH", "Output file (default: first input's name)"],
      [:title, :value, "--title TITLE", "Book title (default: first heading, else file name)"],
      [:author, :value, "--author AUTHOR", "Book author"],
      [:language, :value, "--language CODE", "Language code (default: en)"],
      [:stylesheets, :list, "--css FILE", "Extra stylesheet; may be given several times"],
      [:strict, :flag, "--strict", "Treat warnings (missing images, stylesheets) as errors"],
      [:help, :flag, "-h", "--help", "Show this help"]
    ].freeze

    def initialize(formats:)
      @formats = formats
    end

    def parse(argv)
      values = DEFAULTS.dup
      inputs = build(values).parse(argv)
      Options.new(inputs:, **values).tap { |options| validate(options) }
    rescue OptionParser::ParseError => e
      raise UsageError, e.message
    end

    def usage = build(DEFAULTS.dup).help

    private

    def build(values)
      OptionParser.new(banner) do |parser|
        SWITCHES.each { |key, store, *spec| parser.on(*spec) { |v| STORE.fetch(store).call(values, key, v) } }
      end
    end

    def banner
      "Usage: bookbind INPUT [INPUT...] --to FORMAT [options]\nFormats: #{@formats.join(', ')}\n\n"
    end

    def validate(options)
      return if options.help

      require_value(options.inputs.first, "no input files given")
      require_value(options.target, "missing --to FORMAT")
      require_files(options.inputs + options.stylesheets)
    end

    def require_value(value, message)
      raise UsageError, message unless value
    end

    def require_files(paths)
      missing = paths.reject { |path| File.file?(path) }
      raise UsageError, "file not found: #{missing.join(', ')}" if missing.any?
    end
  end
end
