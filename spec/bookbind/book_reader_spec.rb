# frozen_string_literal: true

RSpec.describe Bookbind::BookReader do
  let(:warnings) { instance_spy(Bookbind::LenientPolicy) }
  let(:first) { chapter("First", ["/a.css"], ["w1"]) }
  let(:second) { chapter("Second", ["/a.css", "/b.css"], []) }
  let(:reader) { double("reader") }
  let(:options) do
    instance_double(Bookbind::Options, title: nil, author: "A", language: "en", stylesheets: ["extra.css"])
  end

  def chapter(title, stylesheets, warns)
    Bookbind::Chapter.new(html: "", title:, stylesheets:, warnings: warns, source: "x")
  end

  subject(:book) do
    allow(reader).to receive(:read).with("1.txt", :scratch).and_return(first)
    allow(reader).to receive(:read).with("2.txt", :scratch).and_return(second)
    described_class.new(sources: [["1.txt", reader], ["2.txt", reader]], warnings:).read(options, :scratch)
  end

  it "reads chapters in order" do
    expect(book.chapters).to eq([first, second])
  end

  it "reports each chapter's warnings" do
    book
    expect(warnings).to have_received(:report).with(["w1"]).ordered
    expect(warnings).to have_received(:report).with([]).ordered
  end

  it "builds metadata, titling the book after the first chapter" do
    expect(book.metadata).to have_attributes(title: "First", author: "A", language: "en")
  end

  it "prefers an explicit title" do
    allow(options).to receive(:title).and_return("Mine")
    expect(book.metadata.title).to eq("Mine")
  end

  it "collects unique chapter stylesheets, then --css ones last" do
    expect(book.metadata.stylesheets).to eq(["/a.css", "/b.css", File.expand_path("extra.css")])
  end
end
