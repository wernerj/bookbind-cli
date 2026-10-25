# frozen_string_literal: true

require_relative "error"

module Bookbind
  class ConversionError < Error
    def exit_code = 2
  end
end
