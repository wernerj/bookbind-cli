# frozen_string_literal: true

RSpec.describe "bookbind executable" do
  around { |example| Dir.mktmpdir { |dir| @dir = dir and example.run } }

  let(:txt) { fixture("sample.txt") }

  it "prints usage for --help" do
    run = bookbind("--help")
    expect([run.exit_code, run.stdout]).to match([0, /Usage: bookbind INPUT/])
  end

  {
    "no arguments" => [[], "no input files given"],
    "an unsupported input format" => [[__FILE__, "--to", "epub"], "unsupported input format '.rb'"],
    "an unsupported output format" => [["IN", "--to", "pdf"], "unsupported output format 'pdf'"],
    "a missing input file" => [["missing.txt", "--to", "epub"], "file not found: missing.txt"]
  }.each do |name, (args, message)|
    it "exits 1 for #{name} with a readable message" do
      run = bookbind(*args.map { |arg| arg == "IN" ? txt : arg })
      expect([run.exit_code, run.stderr]).to match([1, /bookbind: .*#{Regexp.escape(message)}/])
      expect(run.stderr).not_to include("from /") # no stack trace
    end
  end

  it "exits 3 with install instructions when pandoc is missing" do
    run = bookbind(txt, "--to", "epub", "-o", File.join(@dir, "x.epub"), env: { "PATH" => @dir })
    expect([run.exit_code, run.stderr]).to match([3, /pandoc not found.*pandoc.org/])
  end

  it "exits 2 when the output cannot be written", :requires_pandoc do
    run = bookbind(txt, "--to", "epub", "-o", File.join(@dir, "no", "such", "dir.epub"))
    expect([run.exit_code, run.stderr]).to match([2, /cannot write/])
  end

  it "writes the output next to the current directory by default", :requires_pandoc do
    run = Dir.chdir(@dir) { bookbind(txt, "--to", "epub") }
    expect(run.exit_code).to eq(0), run.stderr
    expect([run.stdout, File.exist?(File.join(@dir, "sample.epub"))]).to eq(["Wrote sample.epub\n", true])
  end
end
