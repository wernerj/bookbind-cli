# frozen_string_literal: true

module Bookbind
  # Plain text is converted natively: pandoc has no plain-text reader and would treat * # _ as Markdown.
  class TextReader
    def initialize(normalizer:)
      @normalizer = normalizer
    end

    def read(path, scratch)
      @normalizer.normalize(paragraphs(File.read(path, encoding: "UTF-8").scrub), source: path, scratch:)
    end

    private

    def paragraphs(text)
      text.split(/\n[ \t]*\n/).map(&:strip).reject(&:empty?)
          .map { |block| "<p>#{CGI.escapeHTML(block)}</p>" }.join("\n")
    end
  end
end

Bookbind::READERS.register(".txt") { |deps| Bookbind::TextReader.new(normalizer: deps.normalizer) }
