# frozen_string_literal: true

module Bookbind
  # A temporary directory for intermediate files. Written files get an ordered, unique prefix.
  class Scratch
    attr_reader :dir

    def initialize(dir)
      @dir = dir
      @count = 0
    end

    def path(name) = File.join(dir, name)

    def write(name, content)
      @count += 1
      path(format("%<n>03d-%<name>s", n: @count, name:)).tap { |file| File.write(file, content) }
    end
  end
end
