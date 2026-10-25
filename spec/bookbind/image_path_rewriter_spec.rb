# frozen_string_literal: true

RSpec.describe Bookbind::ImagePathRewriter do
  let(:context) { Bookbind::ChapterContext.new(source: fixture("page.html"), scratch: nil) }

  def rewrite(body)
    Nokogiri::HTML5("<body>#{body}</body>").tap { |doc| described_class.new.apply(doc, context) }.at("body")
  end

  it "makes relative image paths absolute against the input's directory" do
    expect(rewrite('<img src="images/pixel.png">').at("img")["src"]).to eq(fixture("images/pixel.png"))
  end

  it "leaves remote and data: images to pandoc" do
    body = rewrite('<img src="https://x.invalid/a.png"><img src="data:image/png;base64,AAA">')
    expect(body.css("img").map { |img| img["src"] }).to eq(["https://x.invalid/a.png", "data:image/png;base64,AAA"])
  end

  it "replaces a missing image by its alt text and warns" do
    expect(rewrite('<p>a <img src="nope.png" alt="lost"> b</p>').inner_html).to eq("<p>a lost b</p>")
    expect(context.warnings).to eq(["#{fixture('page.html')}: image not found: nope.png"])
  end
end
