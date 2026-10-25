# frozen_string_literal: true

RSpec.describe Bookbind::Registry do
  subject(:registry) { described_class.new("input format") }

  before { registry.register(".txt") { |deps| [:built, deps] } }

  it "builds a registered entry with the given dependencies, ignoring case" do
    expect(registry.build(".TXT", :deps)).to eq(%i[built deps])
  end

  it "lists keys" do
    registry.register(".md") { nil }
    expect(registry.keys).to eq([".md", ".txt"])
  end

  it "rejects unknown keys with the supported list" do
    expect { registry.build(".pdf", nil) }
      .to raise_error(Bookbind::UsageError, "unsupported input format '.pdf' (supported: .txt)")
  end
end
