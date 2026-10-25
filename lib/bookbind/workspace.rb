# frozen_string_literal: true

module Bookbind
  # Hands out a temporary Scratch area that is always removed afterwards.
  class Workspace
    def open
      Dir.mktmpdir("bookbind-") { |dir| yield Scratch.new(dir) }
    end
  end
end
