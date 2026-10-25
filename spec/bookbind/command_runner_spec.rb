# frozen_string_literal: true

RSpec.describe Bookbind::CommandRunner do
  subject(:runner) { described_class.new }

  it "captures stdout and success" do
    result = runner.run("ruby", "-e", "print 'hi'")
    expect([result.stdout, result.success?]).to eq(["hi", true])
  end

  it "captures stderr and failure" do
    result = runner.run("ruby", "-e", "warn 'bad'; exit 1")
    expect([result.stderr, result.success?]).to eq(["bad\n", false])
  end

  it "passes arguments verbatim without a shell" do
    expect(runner.run("echo", "a; echo b $HOME").stdout).to eq("a; echo b $HOME\n")
  end

  it "reports a missing executable as a failed result" do
    expect(runner.run("bookbind-no-such-tool", "--version").success?).to be(false)
  end
end
