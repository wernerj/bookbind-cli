# frozen_string_literal: true

module Bookbind
  # Pandoc only starts a new EPUB chapter at a top-level heading, so every input needs an <h1>.
  # Without one, the headings move up together so that sibling chapters keep the same level.
  class HeadingEnsurer
    HEADINGS = "h1, h2, h3, h4, h5, h6"

    def apply(doc, context)
      headings = doc.css(HEADINGS)
      context.title = title_of(headings.first) || FilenameTitle.for(context.source)
      return if doc.at("h1")

      headings.empty? ? add_title(doc, context.title) : lift(headings)
    end

    private

    def title_of(heading)
      text = heading&.text.to_s.strip
      text unless text.empty?
    end

    def add_title(doc, title) = doc.at("body").prepend_child(doc.create_element("h1", title))

    def lift(headings)
      shift = headings.map { |heading| heading.name[1].to_i }.min - 1
      headings.each { |heading| heading.name = "h#{heading.name[1].to_i - shift}" }
    end
  end
end
