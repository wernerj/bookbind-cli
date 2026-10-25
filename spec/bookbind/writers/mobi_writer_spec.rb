# frozen_string_literal: true

RSpec.describe Bookbind::MobiWriter do
  let(:epub_writer) { instance_double(Bookbind::EpubWriter, write: "/s/book.epub") }
  let(:calibre) { instance_spy(Bookbind::CalibreAdapter, requirement: :calibre_requirement) }
  let(:scratch) { instance_double(Bookbind::Scratch) }

  subject(:writer) { described_class.new(epub_writer:, calibre:) }

  it "declares its extension and needs Calibre" do
    expect([writer.extension, writer.required_tools]).to eq(["mobi", [:calibre_requirement]])
  end

  it "builds the EPUB first and converts it with Calibre" do
    allow(scratch).to receive(:path).with("book.mobi").and_return("/s/book.mobi")
    expect(writer.write(:book, scratch)).to eq("/s/book.mobi")
    expect(epub_writer).to have_received(:write).with(:book, scratch)
    expect(calibre).to have_received(:convert).with("/s/book.epub", "/s/book.mobi")
  end
end
