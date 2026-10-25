# frozen_string_literal: true

RSpec.describe "Converting to MOBI" do
  around { |example| Dir.mktmpdir { |dir| @dir = dir and example.run } }

  let(:output) { File.join(@dir, "book.mobi") }

  it "writes a MOBI file through Calibre", :requires_calibre, :requires_pandoc do
    run = bookbind(fixture("page.html"), fixture("sample.md"), "--to", "mobi", "--output", output)
    expect(run.exit_code).to eq(0), run.stderr
    expect(File.binread(output, 8, 60)).to eq("BOOKMOBI")
  end

  it "exits 3 with install instructions when ebook-convert is missing", :requires_pandoc do
    pandoc_only = File.join(@dir, "bin").tap { |dir| FileUtils.mkdir(dir) }
    FileUtils.ln_s(ToolAvailability.locate("pandoc"), pandoc_only)
    run = bookbind(fixture("sample.txt"), "--to", "mobi", "--output", output, env: { "PATH" => pandoc_only })
    expect([run.exit_code, run.stderr]).to match([3, /ebook-convert not found.*calibre/i])
    expect(File.exist?(output)).to be(false)
  end
end
