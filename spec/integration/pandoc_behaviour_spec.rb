# frozen_string_literal: true

# Documents how pandoc's HTML reader treats source markup, independent of bookbind.
# The README's "Known limitations" section is based on these examples.
RSpec.describe "Pandoc HTML-to-EPUB behaviour", :requires_pandoc do
  around { |example| Dir.mktmpdir { |dir| @dir = dir and example.run } }

  let(:pixel) { fixture("images/pixel.png") }
  let(:data_uri) { "data:image/png;base64,#{[File.binread(pixel)].pack('m0')}" }

  def pandoc_epub(body, *flags)
    File.write(File.join(@dir, "in.html"), "<h1>Chapter</h1>#{body}")
    run_pandoc(*flags)
    EpubInspector.new(File.join(@dir, "out.epub"))
  end

  def run_pandoc(*flags)
    @stderr = Dir.chdir(@dir) do
      Bookbind::CommandRunner.new.run("pandoc", "in.html", "-f", "html", "-t", "epub3", *flags, "-o", "out.epub").stderr
    end
  end

  def chapter(body) = pandoc_epub(body).then { |epub| epub.xml(epub.chapters.first) }

  it "keeps class, id and style on div, span and section" do
    doc = chapter('<div class="box" id="d" style="color:red">x</div><p><span class="s" style="color:blue">y</span></p>')
    expect([doc.at("div.box")&.[]("style"), doc.at("span.s")&.[]("style")]).to eq(["color:red", "color:blue"])
    expect(doc.at("#d")).not_to be_nil
  end

  it "drops class, id and style on paragraphs" do
    para = chapter('<p class="lead" id="p1" style="color:red">text</p>').css("p").last
    expect(para.attributes.keys).to be_empty
  end

  it "moves a heading's id to the wrapping section and keeps its class" do
    doc = chapter('<h2 id="sub" class="fancy">Sub</h2>')
    expect([doc.at("section#sub")&.name, doc.at("h2")["class"]]).to eq(%w[section fancy])
  end

  it "embeds absolute-path and data: images" do
    epub = pandoc_epub(%(<img src="#{pixel}"><img src="#{data_uri}">))
    expect([epub.media.size, epub.unresolved_references]).to eq([2, []])
  end

  it "resolves relative image paths against the working directory, not the HTML file" do
    epub = pandoc_epub('<img src="images/pixel.png">')
    expect(epub.unresolved_references).to eq(["EPUB/images/pixel.png"])
    expect(@stderr).to include("Could not fetch resource images/pixel.png")
  end

  it "leaves a broken reference and a warning when a remote image cannot be fetched" do
    epub = pandoc_epub('<img src="https://bookbind.invalid/x.png">')
    expect(epub.media).to be_empty
    expect(@stderr).to include("Could not fetch resource https://bookbind.invalid/x.png")
  end

  it "copies --css files verbatim without embedding images they reference" do
    File.write(File.join(@dir, "bg.css"), "body { background: url(\"#{pixel}\"); }")
    epub = pandoc_epub("", "--css", "bg.css")
    expect([epub.media, epub.read(epub.styles.first)]).to eq([[], "body { background: url(\"#{pixel}\"); }"])
  end

  it "drops script, style and stylesheet links from the input" do
    epub = pandoc_epub('<script>alert("js")</script><style>.x{color:red}</style><link rel="stylesheet" href="a.css">')
    expect(epub.read(epub.chapters.first)).not_to include("alert", ".x{", "a.css")
  end
end
