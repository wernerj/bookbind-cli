# frozen_string_literal: true

require_relative "error"

module Bookbind
  class UsageError < Error
    def exit_code = 1

    def hint = "Run 'bookbind --help' for usage."
  end
end
