# frozen_string_literal: true

require_relative "error"

module Bookbind
  class MissingToolError < Error
    def exit_code = 3
  end
end
