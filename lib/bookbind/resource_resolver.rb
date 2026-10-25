# frozen_string_literal: true

require "uri"

module Bookbind
  # Decides whether a src/href is pandoc's business (remote, data:) or a local file we must resolve.
  class ResourceResolver
    EXTERNAL = %r{\A(?:[a-z][a-z0-9+.-]*:|//)}i

    def external?(ref) = ref.match?(EXTERNAL) && !ref.start_with?("file:")

    def local_path(ref, base_dir)
      path = ref.delete_prefix("file://").sub(/[?#].*\z/m, "")
      File.expand_path(URI::RFC2396_PARSER.unescape(path), base_dir)
    end
  end
end
