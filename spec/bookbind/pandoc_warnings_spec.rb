# frozen_string_literal: true

RSpec.describe Bookbind::PandocWarnings do
  it "shortens resource warnings and keeps other warnings" do
    stderr = <<~ERR
      [WARNING] Could not fetch resource img/a b.png: PandocResourceNotFound "img/a b.png"
      [WARNING] Could not fetch resource https://x.invalid/y.png: PandocHttpError "https://x.invalid/y.png" "long"
      [WARNING] Duplicate identifier 'x'
      some unrelated line
    ERR
    expect(described_class.parse(stderr)).to eq(
      ["could not fetch resource img/a b.png", "could not fetch resource https://x.invalid/y.png",
       "Duplicate identifier 'x'"]
    )
  end
end
