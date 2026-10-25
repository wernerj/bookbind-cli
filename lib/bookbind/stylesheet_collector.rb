# frozen_string_literal: true

module Bookbind
  # Pandoc ignores <link rel="stylesheet">, so collect the files for --css and drop the links.
  class StylesheetCollector
    def initialize(resolver: ResourceResolver.new)
      @resolver = resolver
    end

    def apply(doc, context)
      stylesheet_links(doc).each do |link|
        add(link["href"], context)
        link.remove
      end
    end

    private

    def stylesheet_links(doc)
      doc.css("link[href]").select { |link| link["rel"].to_s.downcase.split.include?("stylesheet") }
    end

    def add(href, context)
      return context.add_warning("remote stylesheet not embedded: #{href}") if @resolver.external?(href)

      path = @resolver.local_path(href, context.base_dir)
      File.file?(path) ? context.stylesheets << path : context.add_warning("stylesheet not found: #{href}")
    end
  end
end
