# frozen_string_literal: true

RSpec.describe "Bookbind errors" do
  it "maps each expected failure to its exit code" do
    expect([Bookbind::UsageError, Bookbind::ConversionError, Bookbind::MissingToolError]
      .map { |klass| klass.new.exit_code }).to eq([1, 2, 3])
  end

  it "points usage errors to --help and leaves others without a hint" do
    expect(Bookbind::UsageError.new.hint).to include("bookbind --help")
    expect(Bookbind::ConversionError.new.hint).to be_nil
  end
end
