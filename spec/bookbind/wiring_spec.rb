# frozen_string_literal: true

RSpec.describe Bookbind::Wiring do
  def wiring_for(**overrides)
    defaults = { inputs: [fixture("sample.txt")], target: "epub", output: nil, title: nil, author: nil,
                 language: "en", stylesheets: [], strict: false, help: false }
    described_class.new(Bookbind::Options.new(**defaults, **overrides), stderr: StringIO.new)
  end

  it "picks the writer for the target" do
    expect(wiring_for.writer).to be_a(Bookbind::EpubWriter)
  end

  it "computes the output path from the writer" do
    expect(wiring_for.output).to eq("sample.epub")
  end

  it "builds a conversion" do
    expect(wiring_for.conversion).to be_a(Bookbind::Conversion)
  end

  it "rejects unknown targets and input formats before converting" do
    expect { wiring_for(target: "pdf").conversion }.to raise_error(Bookbind::UsageError, /output format 'pdf'/)
    expect { wiring_for(inputs: ["a.pdf"]).conversion }.to raise_error(Bookbind::UsageError, /input format '.pdf'/)
  end

  it "warns leniently by default" do
    expect(wiring_for.warnings).to be_a(Bookbind::LenientPolicy)
  end
end
