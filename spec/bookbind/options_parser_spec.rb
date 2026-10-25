# frozen_string_literal: true

RSpec.describe Bookbind::OptionsParser do
  subject(:parser) { described_class.new(formats: %w[epub mobi]) }

  let(:txt) { fixture("sample.txt") }

  it "parses inputs and all options" do
    options = parser.parse([txt, txt, "--to", "epub", "-o", "out.epub", "--title", "T",
                            "--author", "A", "--language", "cs", "--strict"])
    expect(options).to have_attributes(inputs: [txt, txt], target: "epub", output: "out.epub",
                                       title: "T", author: "A", language: "cs", strict: true)
  end

  it "collects --css given several times" do
    css = fixture("empty.txt")
    expect(parser.parse([txt, "--to", "epub", "--css", css, "--css", css]).stylesheets).to eq([css, css])
  end

  it "uses defaults" do
    expect(parser.parse([txt, "--to", "epub"]))
      .to have_attributes(output: nil, title: nil, author: nil, language: "en", stylesheets: [], strict: false)
  end

  it "accepts --help without inputs" do
    expect(parser.parse(["--help"]).help).to be(true)
  end

  it "lists the formats in the usage text" do
    expect(parser.usage).to include("epub, mobi").and include("--css FILE")
  end

  {
    "no inputs" => [["--to", "epub"], /no input files/],
    "no target" => [["IN"], /missing --to/],
    "unknown option" => [["IN", "--to", "epub", "--bogus"], /invalid option: --bogus/],
    "missing argument" => [["IN", "--to"], /missing argument: --to/],
    "missing input" => [["nope.txt", "--to", "epub"], /file not found: nope.txt/],
    "missing stylesheet" => [["IN", "--to", "epub", "--css", "nope.css"], /file not found: nope.css/]
  }.each do |name, (argv, message)|
    it "rejects #{name}" do
      args = argv.map { |arg| arg == "IN" ? txt : arg }
      expect { parser.parse(args) }.to raise_error(Bookbind::UsageError, message)
    end
  end
end
