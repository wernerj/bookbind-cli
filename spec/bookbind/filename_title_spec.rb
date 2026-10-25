# frozen_string_literal: true

RSpec.describe Bookbind::FilenameTitle do
  it "derives a title from the file name" do
    expect(described_class.for("/a/b/my_first-chapter.md")).to eq("my first chapter")
  end

  it "falls back to Untitled" do
    expect(described_class.for("/a/__.txt")).to eq("Untitled")
  end
end
