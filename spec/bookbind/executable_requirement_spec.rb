# frozen_string_literal: true

RSpec.describe Bookbind::ExecutableRequirement do
  let(:runner) { instance_double(Bookbind::CommandRunner) }
  let(:requirement) { described_class.new(command: "ebook-convert", hint: "Install Calibre.") }

  def answer(success)
    allow(runner).to receive(:run).with("ebook-convert", "--version")
                                  .and_return(Bookbind::CommandResult.new(stdout: "", stderr: "", success:))
  end

  it "passes when the command runs" do
    answer(true)
    expect { requirement.check(runner) }.not_to raise_error
  end

  it "fails with the install hint when the command is missing" do
    answer(false)
    expect { requirement.check(runner) }
      .to raise_error(Bookbind::MissingToolError, "ebook-convert not found. Install Calibre.")
  end
end
