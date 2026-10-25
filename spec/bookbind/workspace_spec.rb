# frozen_string_literal: true

RSpec.describe Bookbind::Workspace do
  it "yields a scratch area and removes it afterwards" do
    dir = described_class.new.open { |scratch| scratch.dir.tap { |d| expect(File.directory?(d)).to be(true) } }
    expect(File.exist?(dir)).to be(false)
  end

  it "removes the scratch area when the block raises" do
    dir = nil
    expect { described_class.new.open { |scratch| (dir = scratch.dir) && raise("boom") } }.to raise_error("boom")
    expect(File.exist?(dir)).to be(false)
  end
end
