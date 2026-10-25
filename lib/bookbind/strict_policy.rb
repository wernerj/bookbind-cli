# frozen_string_literal: true

module Bookbind
  # --strict: any warning aborts the conversion.
  class StrictPolicy
    def initialize(_stream); end

    def report(messages)
      return if messages.empty?

      raise ConversionError, "#{messages.join("\n")}\n(--strict turns warnings into errors)"
    end
  end
end
