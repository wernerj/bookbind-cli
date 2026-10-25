# frozen_string_literal: true

RSpec.describe Bookbind::StrictPolicy do
  it "ignores an empty list" do
    expect { described_class.new(StringIO.new).report([]) }.not_to raise_error
  end

  it "turns warnings into a conversion error" do
    expect { described_class.new(StringIO.new).report(%w[one two]) }
      .to raise_error(Bookbind::ConversionError, "one\ntwo\n(--strict turns warnings into errors)")
  end
end
