# frozen_string_literal: true

RSpec.describe "Converting HTML with images to EPUB", :requires_pandoc do
  around { |example| Dir.mktmpdir { |dir| @dir = dir and example.run } }

  let(:output) { File.join(@dir, "book.epub") }

  def convert(name, *flags)
    bookbind(fixture(name), "--to", "epub", "--output", output, *flags)
  end

  def epub_for(name)
    run = convert(name)
    expect(run.exit_code).to eq(0), run.stderr
    EpubInspector.new(output)
  end

  it "embeds a local image referenced relative to the HTML file" do
    epub = epub_for("page.html")
    expect(epub.media.size).to eq(1)
    expect(epub.references(epub.chapters.first)).to include(*epub.media)
    expect(epub.unresolved_references).to be_empty
  end

  it "drops scripts and ignores the document <title>" do
    epub = epub_for("page.html")
    expect(epub.read(epub.chapters.first)).not_to include("dropped")
    expect(epub.opf.at("title").text).to eq("HTML Chapter")
  end

  it "warns about a missing image, keeps going and leaves no broken reference" do
    run = convert("missing_image.html")
    expect(run.exit_code).to eq(0)
    expect(run.stderr).to match(%r{warning: .*missing_image.html: image not found: images/nope.png})
    expect(EpubInspector.new(output).unresolved_references).to be_empty
  end

  it "fails with exit code 2 on a missing image under --strict and writes nothing" do
    run = convert("missing_image.html", "--strict")
    expect([run.exit_code, run.stderr]).to match([2, /image not found.*--strict/m])
    expect(File.exist?(output)).to be(false)
  end

  it "converts malformed HTML" do
    expect(epub_for("malformed.html").media.size).to eq(1)
  end
end

RSpec.describe "Converting HTML with CSS to EPUB", :requires_pandoc do
  around { |example| Dir.mktmpdir { |dir| @dir = dir and example.run } }

  let(:output) { File.join(@dir, "book.epub") }

  def convert(*args)
    bookbind(*args, "--to", "epub", "--output", output)
  end

  def epub_for(*args)
    run = convert(*args)
    expect(run.exit_code).to eq(0), run.stderr
    EpubInspector.new(output)
  end

  it "embeds the linked and the inline stylesheet and links both from the chapter" do
    epub = epub_for(fixture("page.html"))
    expect(epub.styles.map { |css| epub.read(css) }.join)
      .to include(".chapter-title { color: #8b0000; }", "figure { text-align: center; }")
    expect(epub.references(epub.chapters.first)).to include(*epub.styles)
    expect(epub.unresolved_references).to be_empty
  end

  it "keeps the classes the stylesheet rules target" do
    epub = epub_for(fixture("page.html"))
    chapter = epub.xml(epub.chapters.first)
    expect([chapter.at("h1")["class"], chapter.at("div")["class"]]).to eq(%w[chapter-title note])
  end

  it "adds --css stylesheets after the ones found in the HTML" do
    epub = epub_for(fixture("page.html"), "--css", fixture("css/extra.css"))
    expect(epub.styles.size).to eq(3)
    expect(epub.read(epub.styles.max_by { |css| css[/\d+/].to_i })).to include("#ffffe0")
  end

  it "warns about a missing stylesheet and still converts" do
    run = convert(fixture("missing_css.html"))
    expect(run.exit_code).to eq(0)
    expect(run.stderr).to include("stylesheet not found: css/nope.css")
  end

  it "fails on a missing stylesheet under --strict" do
    expect(convert(fixture("missing_css.html"), "--strict").exit_code).to eq(2)
  end
end
