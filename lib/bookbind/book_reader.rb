# frozen_string_literal: true

module Bookbind
  # Reads every input with its reader and assembles the Book.
  class BookReader
    def initialize(sources:, warnings:)
      @sources = sources
      @warnings = warnings
    end

    def read(options, scratch)
      chapters = @sources.map { |path, reader| reader.read(path, scratch) }
      chapters.each { |chapter| @warnings.report(chapter.warnings) }
      Book.new(chapters:, metadata: metadata(options, chapters))
    end

    private

    def metadata(options, chapters)
      Metadata.new(title: options.title || chapters.first.title, author: options.author,
                   language: options.language, stylesheets: stylesheets(options, chapters))
    end

    # User stylesheets come last so their rules win.
    def stylesheets(options, chapters)
      (chapters.flat_map(&:stylesheets) + options.stylesheets.map { |css| File.expand_path(css) }).uniq
    end
  end
end
