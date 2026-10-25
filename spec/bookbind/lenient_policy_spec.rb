# frozen_string_literal: true

RSpec.describe Bookbind::LenientPolicy do
  it "prints each warning" do
    stream = StringIO.new
    described_class.new(stream).report(%w[one two])
    expect(stream.string).to eq("bookbind: warning: one\nbookbind: warning: two\n")
  end
end
