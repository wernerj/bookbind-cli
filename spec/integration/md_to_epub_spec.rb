# frozen_string_literal: true

RSpec.describe "Converting Markdown to EPUB", :requires_pandoc do
  around { |example| Dir.mktmpdir { |dir| @dir = dir and example.run } }

  let(:output) { File.join(@dir, "book.epub") }

  def convert(name)
    run = bookbind(fixture(name), "--to", "epub", "--output", output)
    expect(run.exit_code).to eq(0), run.stderr
    EpubInspector.new(output)
  end

  def first_chapter(epub) = epub.xml(epub.chapters.first)

  it "renders Markdown formatting and titles the book after the first heading" do
    epub = convert("sample.md")
    chapter = first_chapter(epub)
    expect(%w[em strong code li].map { |tag| chapter.css(tag).size }).to eq([1, 1, 1, 2])
    expect(epub.opf.at("title").text).to eq("Markdown Chapter")
    expect(epub.unresolved_references).to be_empty
  end

  it "keeps unicode intact in text, title and navigation" do
    epub = convert("unicode.md")
    expect(epub.opf.at("title").text).to eq("Příliš žluťoučký kůň ✓")
    expect(first_chapter(epub).text).to include("„uvozovky“, emoji 📚, 日本語")
    expect(epub.nav_titles).to eq(["Příliš žluťoučký kůň ✓"])
  end

  it "keeps nested headings in one chapter, promoting the first heading instead of adding the file name" do
    epub = convert("nested_headings.md")
    expect(epub.chapters.size).to eq(1)
    expect(epub.opf.at("title").text).to eq("Starts at level two")
    expect(first_chapter(epub).css("h1, h2, h3, h4").map(&:name)).to eq(%w[h1 h3 h4])
    expect(epub.nav_titles.first).to eq("Starts at level two")
  end
end
