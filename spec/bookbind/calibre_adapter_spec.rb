# frozen_string_literal: true

RSpec.describe Bookbind::CalibreAdapter do
  let(:runner) { instance_double(Bookbind::CommandRunner) }
  let(:ok) { Bookbind::CommandResult.new(stdout: "", stderr: "", success: true) }

  subject(:adapter) { described_class.new(runner:) }

  it "runs ebook-convert with the exact arguments" do
    expect(runner).to receive(:run).with("ebook-convert", "/s/book.epub", "/s/book.mobi").and_return(ok)
    adapter.convert("/s/book.epub", "/s/book.mobi")
  end

  it "raises a conversion error with the tail of Calibre's output" do
    output = (1..10).map { |n| "line #{n}" }.join("\n")
    allow(runner).to receive(:run).and_return(ok.with(success: false, stdout: output, stderr: "Boom"))
    expect { adapter.convert("a.epub", "a.mobi") }
      .to raise_error(Bookbind::ConversionError, "ebook-convert failed:\nline 8\nline 9\nline 10\nBoom")
  end

  it "describes the tool it needs, with install instructions" do
    expect { adapter.requirement.check(instance_double(Bookbind::CommandRunner, run: ok.with(success: false))) }
      .to raise_error(Bookbind::MissingToolError, /ebook-convert not found.*calibre/i)
  end
end
