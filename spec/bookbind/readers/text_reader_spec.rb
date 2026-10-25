# frozen_string_literal: true

RSpec.describe Bookbind::TextReader do
  let(:normalizer) { instance_double(Bookbind::HtmlNormalizer) }
  let(:path) { fixture("sample.txt") }

  def html_for(path)
    captured = nil
    allow(normalizer).to receive(:normalize) { |html, **| captured = html }
    described_class.new(normalizer:).read(path, :scratch)
    captured
  end

  it "wraps blank-line separated blocks in escaped paragraphs" do
    expect(html_for(path)).to eq(
      "<p>First paragraph with *stars* and _underscores_ and # hashes.</p>\n" \
      "<p>Second &lt;paragraph&gt; &amp; &quot;quotes&quot;.\nStill second.</p>\n<p>Third.</p>"
    )
  end

  it "passes source and scratch to the normalizer" do
    expect(normalizer).to receive(:normalize).with(anything, source: path, scratch: :scratch).and_return(:chapter)
    expect(described_class.new(normalizer:).read(path, :scratch)).to eq(:chapter)
  end

  it "produces no paragraphs for an empty file" do
    expect(html_for(fixture("empty.txt"))).to eq("")
  end
end
