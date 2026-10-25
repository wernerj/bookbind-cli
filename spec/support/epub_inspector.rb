# frozen_string_literal: true

require "pathname"
require "zip"

# Reads an EPUB archive so specs can assert on its structure.
class EpubInspector
  attr_reader :entries

  def initialize(path)
    @files = {}
    Zip::File.open(path) { |zip| zip.each { |entry| @files[entry.name] = zip.read(entry.name) } }
    @entries = @files.keys
  end

  def read(name) = @files.fetch(name)

  def xml(name) = Nokogiri::XML(read(name)).tap(&:remove_namespaces!)

  def opf = xml(xml("META-INF/container.xml").at("rootfile")["full-path"])

  def chapters = entries.grep(%r{\AEPUB/text/ch\d+\.xhtml\z}).sort

  def media = entries.grep(%r{\AEPUB/media/})

  def styles = entries.grep(%r{\AEPUB/styles/.+\.css\z})

  def nav_titles = xml("EPUB/nav.xhtml").css("nav[type=toc] a").map { |a| a.text.strip }

  def references(name)
    doc = xml(name)
    (doc.css("img").map { |n| n["src"] } + doc.css("link").map { |n| n["href"] }).map do |ref|
      Pathname(File.dirname(name)).join(ref).cleanpath.to_s
    end
  end

  def unresolved_references = (chapters + ["EPUB/nav.xhtml"]).flat_map { |c| references(c) } - entries
end
