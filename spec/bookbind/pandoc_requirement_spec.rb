# frozen_string_literal: true

RSpec.describe Bookbind::PandocRequirement do
  let(:runner) { instance_double(Bookbind::CommandRunner) }

  def with_output(stdout, success: true)
    allow(runner).to receive(:run).with("pandoc", "--version")
                                  .and_return(Bookbind::CommandResult.new(stdout:, stderr: "", success:))
  end

  it "accepts pandoc 3.0 and newer" do
    with_output("pandoc 3.12.1\nFeatures: +server\n")
    expect { described_class.new.check(runner) }.not_to raise_error
  end

  it "rejects older pandoc with install instructions" do
    with_output("pandoc 2.19.2\n")
    expect { described_class.new.check(runner) }
      .to raise_error(Bookbind::MissingToolError, /pandoc 2.19.2 is too old.*brew install pandoc/)
  end

  it "reports missing pandoc" do
    with_output("", success: false)
    expect { described_class.new.check(runner) }.to raise_error(Bookbind::MissingToolError, /pandoc not found/)
  end
end
