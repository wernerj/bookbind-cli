# frozen_string_literal: true

RSpec.describe Bookbind::PandocAdapter do
  let(:runner) { instance_double(Bookbind::CommandRunner) }
  let(:warnings) { instance_spy(Bookbind::LenientPolicy) }
  let(:ok) { Bookbind::CommandResult.new(stdout: "<p>x</p>", stderr: "", success: true) }
  let(:metadata) do
    Bookbind::Metadata.new(title: "T", author: "A", language: "cs", stylesheets: ["/a.css", "/b.css"])
  end

  subject(:adapter) { described_class.new(runner:, warnings:) }

  it "converts markdown to html" do
    expect(runner).to receive(:run).with("pandoc", "--from", "markdown-auto_identifiers", "--to", "html",
                                         "in.md").and_return(ok)
    expect(adapter.markdown_to_html("in.md")).to eq("<p>x</p>")
  end

  it "builds the exact epub command" do
    expect(runner).to receive(:run).with(
      "pandoc", "--from", "html", "--to", "epub3", "--split-level=1", "--toc",
      "--metadata", "title=T", "--metadata", "author=A", "--metadata", "lang=cs",
      "--css", "/a.css", "--css", "/b.css", "--output", "out.epub", "1.html", "2.html"
    ).and_return(ok)
    adapter.to_epub(chapters: ["1.html", "2.html"], metadata:, output: "out.epub")
  end

  it "omits metadata that is not set" do
    bare = metadata.with(author: nil, stylesheets: [])
    expect(runner).to receive(:run) { |*args| expect(args.join(" ")).not_to include("author", "--css") }.and_return(ok)
    adapter.to_epub(chapters: ["1.html"], metadata: bare, output: "o.epub")
  end

  it "reports pandoc warnings" do
    allow(runner).to receive(:run).and_return(ok.with(stderr: "[WARNING] Something odd\n"))
    adapter.markdown_to_html("in.md")
    expect(warnings).to have_received(:report).with(["pandoc: Something odd"])
  end

  it "raises a conversion error with pandoc's message on failure" do
    allow(runner).to receive(:run).and_return(ok.with(success: false, stderr: "Unknown option\n"))
    expect do
      adapter.markdown_to_html("in.md")
    end.to raise_error(Bookbind::ConversionError, "pandoc failed: Unknown option")
  end
end
