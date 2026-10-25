# frozen_string_literal: true

RSpec.describe "Combining several inputs into one book", :requires_pandoc do
  around { |example| Dir.mktmpdir { |dir| @dir = dir and example.run } }

  let(:output) { File.join(@dir, "book.epub") }

  def epub_for(*names)
    run = bookbind(*names.map { |name| fixture(name) }, "--to", "epub", "--output", output)
    expect(run.exit_code).to eq(0), run.stderr
    EpubInspector.new(output)
  end

  def chapter_headings(epub) = epub.chapters.map { |chapter| epub.xml(chapter).at("h1").text }

  it "creates one chapter per input, in the order given" do
    epub = epub_for("sample.md", "sample.txt", "page.html", "nested_headings.md")
    expect(chapter_headings(epub)).to eq(["Markdown Chapter", "sample", "HTML Chapter", "nested headings"])
    expect(epub.unresolved_references).to be_empty
  end

  it "follows the input order, not the file names" do
    expect(chapter_headings(epub_for("sample.txt", "sample.md"))).to eq(["sample", "Markdown Chapter"])
  end

  it "titles the book after the first input and lists every chapter in the nav" do
    epub = epub_for("sample.txt", "sample.md")
    expect(epub.opf.at("title").text).to eq("sample")
    expect(epub.nav_titles).to eq(["sample", "Markdown Chapter"])
  end

  it "embeds a stylesheet and an image shared by two chapters only once" do
    epub = epub_for("page.html", "second_page.html")
    expect([epub.chapters.size, epub.media.size]).to eq([2, 1])
    expect(epub.styles.count { |css| epub.read(css).include?(".chapter-title") }).to eq(1)
    expect(epub.unresolved_references).to be_empty
  end

  it "links every chapter from the nav, even when two inputs share a heading" do
    epub = epub_for("sample.md", "sample.md")
    targets = epub.xml("EPUB/nav.xhtml").css("nav[type=toc] a").map { |a| a["href"] }
    expect(targets.map { |href| href.split("#").first }).to eq(%w[text/ch001.xhtml text/ch002.xhtml])
    expect(targets.uniq.size).to eq(2)
  end

  it "defaults the output name to the first input" do
    run = Dir.chdir(@dir) { bookbind(fixture("sample.md"), fixture("sample.txt"), "--to", "epub") }
    expect([run.exit_code, File.exist?(File.join(@dir, "sample.epub"))]).to eq([0, true])
  end
end
