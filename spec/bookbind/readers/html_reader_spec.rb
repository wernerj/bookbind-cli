# frozen_string_literal: true

RSpec.describe Bookbind::HtmlReader do
  subject(:reader) { described_class.new(normalizer: Bookbind::HtmlNormalizer.standard) }

  around { |example| Dir.mktmpdir { |dir| @scratch = Bookbind::Scratch.new(dir) and example.run } }

  def read(name) = reader.read(fixture(name), @scratch)

  def body(name) = Nokogiri::HTML5.fragment(read(name).html)

  it "returns the body only, without head elements such as scripts" do
    expect(body("page.html").css("script, title, meta")).to be_empty
  end

  it "rewrites relative image paths to absolute ones" do
    expect(body("page.html").at("img")["src"]).to eq(fixture("images/pixel.png"))
  end

  it "titles the chapter after its first heading" do
    expect(read("page.html").title).to eq("HTML Chapter")
  end

  it "warns about missing images and keeps their alt text" do
    chapter = read("missing_image.html")
    expect(chapter.warnings).to eq(["#{fixture('missing_image.html')}: image not found: images/nope.png"])
    expect(Nokogiri::HTML5.fragment(chapter.html).at("p").text).to eq("Before lost picture after.")
  end

  it "adds a heading derived from the file name when there is none" do
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "no_heading.html"), "<p>Just text</p>")
      chapter = reader.read(File.join(dir, "no_heading.html"), @scratch)
      expect([chapter.html, chapter.title]).to eq(["<h1>no heading</h1><p>Just text</p>", "no heading"])
    end
  end

  it "discovers linked stylesheets and extracts inline <style> blocks, in that order" do
    linked, inline = read("page.html").stylesheets
    expect(linked).to eq(fixture("css/style.css"))
    expect(File.read(inline)).to include("figure { text-align: center; }")
  end

  it "keeps no <link> or <style> in the chapter body" do
    expect(body("page.html").css("link, style")).to be_empty
  end

  it "warns about a missing stylesheet" do
    chapter = read("missing_css.html")
    expect([chapter.stylesheets, chapter.warnings])
      .to eq([[], ["#{fixture('missing_css.html')}: stylesheet not found: css/nope.css"]])
  end

  it "survives malformed markup" do
    expect(body("malformed.html").css("h1, td").map(&:text)).to eq(["Malformed Page", "cell"])
  end
end
