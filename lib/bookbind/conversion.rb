# frozen_string_literal: true

module Bookbind
  # Runs one conversion: check tools, read, write in scratch space, then copy the result out.
  class Conversion
    def initialize(tool_check:, book_reader:, writer:, workspace:)
      @tool_check = tool_check
      @book_reader = book_reader
      @writer = writer
      @workspace = workspace
    end

    def call(options, output)
      @tool_check.verify(@writer.required_tools)
      @workspace.open { |scratch| publish(build(options, scratch), output) }
    end

    private

    def build(options, scratch) = @writer.write(@book_reader.read(options, scratch), scratch)

    def publish(file, output)
      FileUtils.cp(file, output)
    rescue SystemCallError => e
      raise ConversionError, "cannot write #{output}: #{e.message}"
    end
  end
end
