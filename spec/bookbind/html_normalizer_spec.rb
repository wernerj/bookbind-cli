# frozen_string_literal: true

RSpec.describe Bookbind::HtmlNormalizer do
  it "runs each step on the parsed document and returns the body as a chapter" do
    step = Class.new do
      def apply(doc, context)
        doc.at("p")["class"] = "seen"
        context.title = "Stepped"
      end
    end
    chapter = described_class.new(steps: [step.new]).normalize("<p>x</p>", source: "a.txt", scratch: :s)
    expect([chapter.html, chapter.title, chapter.source]).to eq(['<p class="seen">x</p>', "Stepped", "a.txt"])
  end
end
