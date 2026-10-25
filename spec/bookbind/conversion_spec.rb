# frozen_string_literal: true

RSpec.describe Bookbind::Conversion do
  let(:tool_check) { instance_spy(Bookbind::ToolCheck) }
  let(:book_reader) { instance_double(Bookbind::BookReader, read: :book) }
  let(:writer) { instance_double(Bookbind::EpubWriter, required_tools: [:calibre]) }

  around { |example| Dir.mktmpdir { |dir| @dir = dir and example.run } }

  subject(:conversion) do
    described_class.new(tool_check:, book_reader:, writer:, workspace: Bookbind::Workspace.new)
  end

  before do
    allow(writer).to receive(:write) { |_book, scratch| scratch.write("book.epub", "EPUB") }
  end

  it "checks tools, builds the book in scratch space and copies it to the output" do
    conversion.call(:options, File.join(@dir, "out.epub"))
    expect(tool_check).to have_received(:verify).with([:calibre])
    expect(File.read(File.join(@dir, "out.epub"))).to eq("EPUB")
  end

  it "turns an unwritable output into a conversion error" do
    expect { conversion.call(:options, File.join(@dir, "missing", "out.epub")) }
      .to raise_error(Bookbind::ConversionError, /cannot write .*out.epub/)
  end
end
