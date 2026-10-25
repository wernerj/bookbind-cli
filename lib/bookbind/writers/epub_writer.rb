# frozen_string_literal: true

module Bookbind
  # Pandoc embeds the referenced images and the --css stylesheets into the EPUB.
  class EpubWriter
    def initialize(pandoc:)
      @pandoc = pandoc
    end

    def extension = "epub"

    def required_tools = []

    def write(book, scratch)
      scratch.path("book.epub").tap do |output|
        @pandoc.to_epub(chapters: chapter_files(book, scratch), metadata: book.metadata, output:)
      end
    end

    private

    def chapter_files(book, scratch) = book.chapters.map { |chapter| scratch.write("chapter.html", chapter.html) }
  end
end

Bookbind::WRITERS.register("epub") { |deps| Bookbind::EpubWriter.new(pandoc: deps.pandoc) }
