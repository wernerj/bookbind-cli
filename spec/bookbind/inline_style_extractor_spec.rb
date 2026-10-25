# frozen_string_literal: true

RSpec.describe Bookbind::InlineStyleExtractor do
  let(:scratch) { instance_double(Bookbind::Scratch) }
  let(:context) { Bookbind::ChapterContext.new(source: "a.html", scratch:) }

  it "writes each non-empty <style> block to a css file and removes it" do
    allow(scratch).to receive(:write).with("inline.css", ".a{}").and_return("/s/001-inline.css")
    doc = Nokogiri::HTML5("<head><style>.a{}</style><style> </style></head><body><style>.a{}</style></body>")
    described_class.new.apply(doc, context)
    expect(context.stylesheets).to eq(["/s/001-inline.css", "/s/001-inline.css"])
    expect(doc.css("style")).to be_empty
  end
end
