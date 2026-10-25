# frozen_string_literal: true

module Bookbind
  # Builds pandoc command lines and runs them.
  class PandocAdapter
    EPUB_FLAGS = ["--from", "html", "--to", "epub3", "--split-level=2", "--toc"].freeze

    def initialize(runner:, warnings:, parser: PandocWarnings)
      @runner = runner
      @warnings = warnings
      @parser = parser
    end

    # Without explicit ids from this step, the EPUB step generates unique ids across all chapters.
    def markdown_to_html(path) = run("--from", "markdown-auto_identifiers", "--to", "html", path).stdout

    def to_epub(chapters:, metadata:, output:)
      run(*EPUB_FLAGS, *metadata_args(metadata), *css_args(metadata), "--output", output, *chapters)
    end

    private

    def metadata_args(metadata)
      { title: metadata.title, author: metadata.author, lang: metadata.language }
        .compact.flat_map { |key, value| ["--metadata", "#{key}=#{value}"] }
    end

    def css_args(metadata) = metadata.stylesheets.flat_map { |css| ["--css", css] }

    def run(*)
      result = @runner.run("pandoc", *)
      raise ConversionError, "pandoc failed: #{result.stderr.strip}" unless result.success?

      @warnings.report(@parser.parse(result.stderr).map { |warning| "pandoc: #{warning}" })
      result
    end
  end
end
