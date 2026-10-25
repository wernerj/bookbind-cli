# frozen_string_literal: true

module Bookbind
  class FilenameTitle
    def self.for(path)
      title = File.basename(path, ".*").tr("_-", " ").squeeze(" ").strip
      title.empty? ? "Untitled" : title
    end
  end
end
