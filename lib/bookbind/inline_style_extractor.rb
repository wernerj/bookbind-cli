# frozen_string_literal: true

module Bookbind
  # Pandoc drops <style> blocks, so move each one into a temporary .css file for --css.
  class InlineStyleExtractor
    def apply(doc, context)
      doc.css("style").each do |style|
        context.stylesheets << context.scratch.write("inline.css", style.text) unless style.text.strip.empty?
        style.remove
      end
    end
  end
end
