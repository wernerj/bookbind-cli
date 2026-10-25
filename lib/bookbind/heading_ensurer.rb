# frozen_string_literal: true

module Bookbind
  # Pandoc only starts a new EPUB chapter at an <h1>, so every input needs one.
  class HeadingEnsurer
    HEADINGS = "h1, h2, h3, h4, h5, h6"

    def apply(doc, context)
      fallback = FilenameTitle.for(context.source)
      context.title = first_heading(doc) || fallback
      doc.at("body").prepend_child(doc.create_element("h1", fallback)) unless doc.at("h1")
    end

    private

    def first_heading(doc)
      text = doc.at_css(HEADINGS)&.text.to_s.strip
      text unless text.empty?
    end
  end
end
