# frozen_string_literal: true

module Bookbind
  # Base for expected failures. Each subclass knows its exit code, so callers never branch on type.
  class Error < StandardError
    def exit_code = 2

    def hint = nil
  end
end
