# frozen_string_literal: true

require "cgi"
require "fileutils"
require "nokogiri"
require "open3"
require "optparse"
require "tmpdir"

require_relative "bookbind/registry"

module Bookbind
  READERS = Registry.new("input format")
  WRITERS = Registry.new("output format")
end

%w[. readers writers].each do |dir|
  Dir[File.join(__dir__, "bookbind", dir, "*.rb")].each { |file| require file }
end
