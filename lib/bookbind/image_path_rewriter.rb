# frozen_string_literal: true

module Bookbind
  # Pandoc resolves relative image paths against its working directory, so make them absolute.
  # A missing image would leave a broken reference in the EPUB; it becomes its alt text instead.
  class ImagePathRewriter
    def initialize(resolver: ResourceResolver.new)
      @resolver = resolver
    end

    def apply(doc, context)
      doc.css("img[src]").reject { |img| @resolver.external?(img["src"]) }.each { |img| rewrite(img, context) }
    end

    private

    def rewrite(img, context)
      path = @resolver.local_path(img["src"], context.base_dir)
      File.file?(path) ? img["src"] = path : drop(img, context)
    end

    def drop(img, context)
      context.add_warning("image not found: #{img['src']}")
      img.replace(img.document.create_text_node(img["alt"].to_s))
    end
  end
end
