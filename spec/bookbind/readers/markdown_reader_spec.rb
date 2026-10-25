# frozen_string_literal: true

RSpec.describe Bookbind::MarkdownReader do
  let(:pandoc) { instance_double(Bookbind::PandocAdapter, markdown_to_html: "<h1>Hi</h1>") }
  let(:normalizer) { instance_double(Bookbind::HtmlNormalizer) }

  it "converts with pandoc and normalizes the resulting html" do
    expect(normalizer).to receive(:normalize).with("<h1>Hi</h1>", source: "a.md", scratch: :scratch)
                                             .and_return(:chapter)
    expect(described_class.new(pandoc:, normalizer:).read("a.md", :scratch)).to eq(:chapter)
    expect(pandoc).to have_received(:markdown_to_html).with("a.md")
  end
end
