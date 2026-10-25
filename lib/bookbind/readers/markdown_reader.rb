# frozen_string_literal: true

module Bookbind
  class MarkdownReader
    def initialize(pandoc:, normalizer:)
      @pandoc = pandoc
      @normalizer = normalizer
    end

    def read(path, scratch)
      @normalizer.normalize(@pandoc.markdown_to_html(path), source: path, scratch:)
    end
  end
end

Bookbind::READERS.register(".md") do |deps|
  Bookbind::MarkdownReader.new(pandoc: deps.pandoc, normalizer: deps.normalizer)
end
