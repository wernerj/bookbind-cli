# frozen_string_literal: true

module Bookbind
  # MOBI is produced from the EPUB by Calibre.
  class MobiWriter
    def initialize(epub_writer:, calibre:)
      @epub_writer = epub_writer
      @calibre = calibre
    end

    def extension = "mobi"

    def required_tools = [@calibre.requirement]

    def write(book, scratch)
      epub = @epub_writer.write(book, scratch)
      scratch.path("book.mobi").tap { |mobi| @calibre.convert(epub, mobi) }
    end
  end
end

Bookbind::WRITERS.register("mobi") do |deps|
  Bookbind::MobiWriter.new(epub_writer: Bookbind::EpubWriter.new(pandoc: deps.pandoc), calibre: deps.calibre)
end
