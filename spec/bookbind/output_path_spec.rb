# frozen_string_literal: true

RSpec.describe Bookbind::OutputPath do
  let(:writer) { instance_double(Bookbind::EpubWriter, extension: "epub") }

  it "defaults to the first input's basename with the writer's extension" do
    options = instance_double(Bookbind::Options, output: nil, inputs: ["docs/my.book.md", "b.txt"])
    expect(described_class.new(options).for(writer)).to eq("my.book.epub")
  end

  it "uses --output when given" do
    options = instance_double(Bookbind::Options, output: "x/out.epub", inputs: ["a.md"])
    expect(described_class.new(options).for(writer)).to eq("x/out.epub")
  end
end
