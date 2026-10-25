# frozen_string_literal: true

RSpec.describe Bookbind::ToolCheck do
  it "checks the baseline and the extra requirements with the runner" do
    baseline = instance_spy(Bookbind::PandocRequirement)
    extra = instance_spy(Bookbind::PandocRequirement)
    described_class.new(runner: :runner, baseline: [baseline]).verify([extra])
    expect([baseline, extra]).to all(have_received(:check).with(:runner))
  end
end
