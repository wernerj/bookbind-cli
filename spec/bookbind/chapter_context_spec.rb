# frozen_string_literal: true

RSpec.describe Bookbind::ChapterContext do
  subject(:context) { described_class.new(source: "docs/a.html", scratch: :scratch) }

  it "resolves the base directory of the source" do
    expect(context.base_dir).to eq(File.expand_path("docs"))
  end

  it "builds a chapter with collected warnings and stylesheets" do
    context.add_warning("oops")
    context.stylesheets << "/s.css"
    context.title = "T"
    expect(context.to_chapter("<p/>")).to eq(
      Bookbind::Chapter.new(html: "<p/>", title: "T", stylesheets: ["/s.css"],
                            warnings: ["docs/a.html: oops"], source: "docs/a.html")
    )
  end
end
