# frozen_string_literal: true

module Bookbind
  # HTML needs no conversion; the normaliser fixes resource paths, styles and headings.
  class HtmlReader
    def initialize(normalizer:)
      @normalizer = normalizer
    end

    def read(path, scratch)
      @normalizer.normalize(File.read(path, encoding: "UTF-8").scrub, source: path, scratch:)
    end
  end
end

Bookbind::READERS.register(".html") { |deps| Bookbind::HtmlReader.new(normalizer: deps.normalizer) }
