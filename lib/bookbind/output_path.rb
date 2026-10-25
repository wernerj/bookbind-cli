# frozen_string_literal: true

module Bookbind
  class OutputPath
    def initialize(options)
      @options = options
    end

    def for(writer)
      @options.output || "#{File.basename(@options.inputs.first, '.*')}.#{writer.extension}"
    end
  end
end
