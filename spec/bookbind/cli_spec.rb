# frozen_string_literal: true

RSpec.describe Bookbind::CLI do
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }
  let(:conversion) { instance_spy(Bookbind::Conversion) }
  let(:wiring) { instance_double(Bookbind::Wiring, conversion:, output: "out.epub") }
  let(:wiring_class) { class_double(Bookbind::Wiring, new: wiring) }
  let(:argv) { [fixture("sample.txt"), "--to", "epub"] }

  subject(:cli) { described_class.new(stdout:, stderr:, wiring: wiring_class) }

  it "runs the conversion and reports the output" do
    expect(cli.run(argv)).to eq(0)
    expect(conversion).to have_received(:call).with(an_instance_of(Bookbind::Options), "out.epub")
    expect(stdout.string).to eq("Wrote out.epub\n")
  end

  it "prints help" do
    expect(cli.run(["--help"])).to eq(0)
    expect(stdout.string).to include("Usage: bookbind")
  end

  it "reports usage errors with a hint and exit code 1" do
    expect(cli.run([])).to eq(1)
    expect(stderr.string).to eq("bookbind: no input files given\nRun 'bookbind --help' for usage.\n")
  end

  it "reports other expected errors with their exit code" do
    allow(conversion).to receive(:call).and_raise(Bookbind::MissingToolError, "pandoc not found")
    expect(cli.run(argv)).to eq(3)
    expect(stderr.string).to eq("bookbind: pandoc not found\n")
  end
end
