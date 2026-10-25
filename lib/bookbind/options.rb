# frozen_string_literal: true

module Bookbind
  Options = Data.define(:inputs, :target, :output, :title, :author, :language, :stylesheets, :strict, :help)
end
