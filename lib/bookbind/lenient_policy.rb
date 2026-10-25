# frozen_string_literal: true

module Bookbind
  # Default warning policy: tell the user and carry on.
  class LenientPolicy
    def initialize(stream)
      @stream = stream
    end

    def report(messages)
      messages.each { |message| @stream.puts "bookbind: warning: #{message}" }
    end
  end
end
