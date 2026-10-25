# frozen_string_literal: true

require_relative "usage_error"

module Bookbind
  # Maps a key (file extension or format name) to a factory block that builds the handler.
  class Registry
    def initialize(kind)
      @kind = kind
      @factories = {}
    end

    def register(key, &factory)
      @factories[key.to_s.downcase] = factory
    end

    def build(key, deps) = fetch(key).call(deps)

    def keys = @factories.keys.sort

    private

    def fetch(key)
      @factories.fetch(key.to_s.downcase) do
        raise UsageError, "unsupported #{@kind} '#{key}' (supported: #{keys.join(', ')})"
      end
    end
  end
end
