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
