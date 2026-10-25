# frozen_string_literal: true

module Bookbind
  # What normalisation steps learn about one input file while they rewrite its HTML.
  class ChapterContext
    attr_reader :source, :scratch, :stylesheets, :warnings
    attr_accessor :title

    def initialize(source:, scratch:)
      @source = source
      @scratch = scratch
      @stylesheets = []
      @warnings = []
    end

    def base_dir = File.dirname(File.expand_path(source))

    def add_warning(message)
      warnings << "#{source}: #{message}"
    end

    def to_chapter(html) = Chapter.new(html:, title:, stylesheets:, warnings:, source:)
  end
end
