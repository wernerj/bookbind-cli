# frozen_string_literal: true

RSpec.describe Bookbind::HeadingEnsurer do
  let(:context) { Bookbind::ChapterContext.new(source: "/x/the_intro.html", scratch: nil) }

  def apply(body)
    Nokogiri::HTML5("<body>#{body}</body>").tap { |doc| described_class.new.apply(doc, context) }
  end

  it "keeps an existing h1 and uses it as the title" do
    doc = apply("<h1>Real</h1><p>x</p>")
    expect([doc.css("h1").map(&:text), context.title]).to eq([["Real"], "Real"])
  end

  it "adds an h1 from the file name when there is no heading" do
    expect(apply("<p>x</p>").at("body").children.first.to_html).to eq("<h1>the intro</h1>")
    expect(context.title).to eq("the intro")
  end

  it "lifts every heading level together when the file has no h1, so sibling chapters stay equal" do
    doc = apply("<h2>Sub</h2><h3>Deep</h3><h2>Next</h2>")
    expect([doc.css("h1, h2, h3").map(&:name), context.title]).to eq([%w[h1 h2 h1], "Sub"])
  end

  it "does not touch levels when an h1 exists" do
    doc = apply("<h1>Top</h1><h2>Sub</h2>")
    expect(doc.css("h1, h2").map(&:name)).to eq(%w[h1 h2])
  end

  it "handles an empty body" do
    expect(apply("").css("h1").map(&:text)).to eq(["the intro"])
  end
end
