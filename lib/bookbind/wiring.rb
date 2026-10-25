# frozen_string_literal: true

module Bookbind
  # Composition root: the one place that builds collaborators from Options.
  # Registered reader and writer factories receive this object to pick what they need.
  class Wiring
    attr_reader :options

    def initialize(options, stderr:, runner: CommandRunner.new)
      @options = options
      @stderr = stderr
      @runner = runner
    end

    def conversion
      Conversion.new(tool_check: ToolCheck.new(runner: @runner), book_reader:, writer:, workspace: Workspace.new)
    end

    def output = OutputPath.new(options).for(writer)

    def writer = @writer ||= WRITERS.build(options.target, self)

    def pandoc = @pandoc ||= PandocAdapter.new(runner: @runner, warnings:)

    def calibre = @calibre ||= CalibreAdapter.new(runner: @runner)

    def normalizer = HtmlNormalizer.standard

    def warnings = @warnings ||= { false => LenientPolicy, true => StrictPolicy }.fetch(options.strict).new(@stderr)

    private

    def book_reader = BookReader.new(sources:, warnings:)

    def sources = options.inputs.map { |path| [path, READERS.build(File.extname(path), self)] }
  end
end
