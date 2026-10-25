# frozen_string_literal: true

RSpec.describe Bookbind::Scratch do
  around { |example| Dir.mktmpdir { |dir| @dir = dir and example.run } }

  subject(:scratch) { described_class.new(@dir) }

  it "writes files with unique, ordered names" do
    paths = [scratch.write("chapter.html", "a"), scratch.write("chapter.html", "b")]
    expect(paths.map { |p| File.basename(p) }).to eq(%w[001-chapter.html 002-chapter.html])
    expect(paths.map { |p| File.read(p) }).to eq(%w[a b])
  end

  it "builds paths inside the directory" do
    expect(scratch.path("book.epub")).to eq(File.join(@dir, "book.epub"))
  end
end
