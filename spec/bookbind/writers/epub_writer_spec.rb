# frozen_string_literal: true

RSpec.describe Bookbind::EpubWriter do
  let(:pandoc) { instance_spy(Bookbind::PandocAdapter) }
  let(:scratch) { instance_double(Bookbind::Scratch, path: "/s/book.epub") }
  let(:metadata) { instance_double(Bookbind::Metadata) }
  let(:chapters) { %w[<p>1</p> <p>2</p>].map { |html| instance_double(Bookbind::Chapter, html:) } }

  subject(:writer) { described_class.new(pandoc:) }

  it "declares its extension and no extra tools" do
    expect([writer.extension, writer.required_tools]).to eq(["epub", []])
  end

  it "writes one file per chapter and asks pandoc for the epub" do
    allow(scratch).to receive(:write) { |_name, html| "/s/#{html.delete('<>/p')}.html" }
    result = writer.write(Bookbind::Book.new(chapters:, metadata:), scratch)
    expect(pandoc).to have_received(:to_epub).with(chapters: ["/s/1.html", "/s/2.html"], metadata:,
                                                   output: "/s/book.epub")
    expect(result).to eq("/s/book.epub")
  end
end
