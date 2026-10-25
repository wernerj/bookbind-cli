# frozen_string_literal: true

module Bookbind
  # Pandoc only starts a new EPUB chapter at an <h1>, so every input needs one.
  class HeadingEnsurer
    HEADINGS = "h1, h2, h3, h4, h5, h6"

    def apply(doc, context)
      return context.title = first_heading(doc) if doc.at("h1")

      heading = leading_heading(doc)
      heading ? promote(heading, context) : add_from_filename(doc, context)
    end

    private

    def first_heading(doc) = text_of(doc.at_css(HEADINGS))

    def leading_heading(doc)
      doc.at_css(HEADINGS) if text_of(doc.at_css(HEADINGS))
    end

    def promote(heading, context)
      context.title = text_of(heading)
      heading.name = "h1"
    end

    def add_from_filename(doc, context)
      context.title = FilenameTitle.for(context.source)
      doc.at("body").prepend_child(doc.create_element("h1", context.title))
    end

    def text_of(node)
      text = node&.text.to_s.strip
      text unless text.empty?
    end
  end
end
