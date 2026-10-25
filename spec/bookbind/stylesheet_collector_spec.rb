# frozen_string_literal: true

RSpec.describe Bookbind::StylesheetCollector do
  let(:context) { Bookbind::ChapterContext.new(source: fixture("page.html"), scratch: nil) }

  def collect(head)
    Nokogiri::HTML5("<head>#{head}</head><body></body>").tap { |doc| described_class.new.apply(doc, context) }
  end

  it "collects linked stylesheets as absolute paths and removes the links" do
    doc = collect('<link rel="stylesheet" href="css/style.css"><link rel="icon" href="x.ico">')
    expect(context.stylesheets).to eq([fixture("css/style.css")])
    expect(doc.css("link").map { |link| link["rel"] }).to eq(["icon"])
  end

  it "matches rel case-insensitively among several values" do
    collect('<link rel="Alternate STYLESHEET" href="css/style.css">')
    expect(context.stylesheets).to eq([fixture("css/style.css")])
  end

  it "warns about missing and remote stylesheets" do
    collect('<link rel="stylesheet" href="nope.css"><link rel="stylesheet" href="https://x.invalid/a.css">')
    expect(context.stylesheets).to be_empty
    expect(context.warnings.map { |w| w.split(": ", 2).last })
      .to eq(["stylesheet not found: nope.css", "remote stylesheet not embedded: https://x.invalid/a.css"])
  end
end
