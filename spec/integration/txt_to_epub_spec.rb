# frozen_string_literal: true

RSpec.describe "Converting a text file to EPUB", :requires_pandoc do
  around { |example| Dir.mktmpdir { |dir| @dir = dir and example.run } }

  let(:output) { File.join(@dir, "book.epub") }

  def convert(*inputs, **flags)
    args = inputs.map { |name| fixture(name) } + ["--to", "epub", "--output", output]
    run = bookbind(*args, *flags.flat_map { |key, value| ["--#{key}", value] })
    expect(run.exit_code).to eq(0), run.stderr
    EpubInspector.new(output)
  end

  it "produces a structurally valid EPUB" do
    epub = convert("sample.txt")
    expect(epub.entries.first).to eq("mimetype")
    expect(epub.read("mimetype")).to eq("application/epub+zip")
    expect(epub.xml("META-INF/container.xml").at("rootfile")["full-path"]).to eq("EPUB/content.opf")
    expect(epub.unresolved_references).to be_empty
  end

  it "writes title, author and language into the OPF metadata" do
    opf = convert("sample.txt", title: "Plain Book", author: "Jane Doe", language: "cs").opf
    expect(%w[title creator language].map { |tag| opf.at(tag).text }).to eq(["Plain Book", "Jane Doe", "cs"])
  end

  it "titles the book after the file name and defaults the language to en" do
    opf = convert("sample.txt").opf
    expect([opf.at("title").text, opf.at("language").text]).to eq(%w[sample en])
  end

  it "keeps Markdown-like characters as literal text, one paragraph per block" do
    epub = convert("sample.txt")
    paragraphs = epub.xml(epub.chapters.first).css("p").map { |p| p.text.squeeze(" \n").tr("\n", " ") }
    expect(paragraphs).to eq(["First paragraph with *stars* and _underscores_ and # hashes.",
                              "Second <paragraph> & \"quotes\". Still second.", "Third."])
  end

  it "lists the chapter in the nav document" do
    expect(convert("sample.txt").nav_titles).to eq(["sample"])
  end

  it "converts an empty file into a chapter with only a heading" do
    epub = convert("empty.txt")
    expect(epub.chapters.size).to eq(1)
    expect(epub.xml(epub.chapters.first).at("h1").text).to eq("empty")
  end
end
