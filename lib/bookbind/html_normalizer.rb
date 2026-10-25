# frozen_string_literal: true

module Bookbind
  # Parses HTML, lets each step rewrite it, and returns the body as a Chapter.
  class HtmlNormalizer
    def initialize(steps:)
      @steps = steps
    end

    def normalize(html, source:, scratch:)
      doc = Nokogiri::HTML5(html)
      context = ChapterContext.new(source:, scratch:)
      @steps.each { |step| step.apply(doc, context) }
      context.to_chapter(doc.at("body").inner_html)
    end
  end
end
