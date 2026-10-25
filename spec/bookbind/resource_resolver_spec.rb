# frozen_string_literal: true

RSpec.describe Bookbind::ResourceResolver do
  subject(:resolver) { described_class.new }

  it "treats URLs with a scheme and protocol-relative URLs as external" do
    refs = ["http://x/a.png", "HTTPS://x/a.png", "data:image/png;base64,AAA", "//cdn.x/a.png"]
    expect(refs.map { |ref| resolver.external?(ref) }).to all(be(true))
  end

  it "treats relative, absolute and file: references as local" do
    expect(["a.png", "../a.png", "/abs/a.png", "file:///abs/a.png"].map { |ref| resolver.external?(ref) })
      .to all(be(false))
  end

  it "resolves local references against the base directory" do
    expect(resolver.local_path("img/a.png", "/docs")).to eq("/docs/img/a.png")
    expect(resolver.local_path("../a.png", "/docs/sub")).to eq("/docs/a.png")
    expect(resolver.local_path("/abs/a.png", "/docs")).to eq("/abs/a.png")
  end

  it "decodes percent escapes and drops file:, query and fragment parts" do
    expect(resolver.local_path("my%20pic.png?v=2#top", "/d")).to eq("/d/my pic.png")
    expect(resolver.local_path("file:///abs/a.png", "/d")).to eq("/abs/a.png")
  end
end
