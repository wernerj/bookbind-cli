# bookbind

Turn text documents into ebooks. `bookbind` combines `.txt`, `.md` and `.html` files into one EPUB or MOBI book, one chapter per file, using [pandoc](https://pandoc.org) and [Calibre](https://calibre-ebook.com).

```sh
bookbind intro.md chapter1.html notes.txt --to epub --title "My Book" --author "Jane Doe"
```

## Install

1. **Ruby 3.3 or newer**, then install the gems from the project folder:
   ```sh
   bundle install
   ```
2. **pandoc 3.0 or newer** (needed for every conversion):
   ```sh
   brew install pandoc            # macOS
   sudo apt install pandoc        # Debian/Ubuntu (check the version: `pandoc --version`)
   ```
   Older distributions ship pandoc 2.x. In that case, get a current release from https://pandoc.org/installing.html.
3. **Calibre** (only for MOBI output). `bookbind` calls Calibre's `ebook-convert`, which must be on your `PATH`:
   ```sh
   brew install --cask calibre    # macOS
   echo 'export PATH="/Applications/calibre.app/Contents/MacOS:$PATH"' >> ~/.zprofile
   sudo apt install calibre       # Debian/Ubuntu
   ```
   Put the PATH line in `~/.zprofile` rather than `~/.zshrc` if you also want scripts and editors (not only interactive shells) to find `ebook-convert`.

`bookbind` checks for both tools before it starts. If one is missing, it exits with code 3 and tells you how to install it.

## Usage

```
Usage: bookbind INPUT [INPUT...] --to FORMAT [options]
Formats: epub, mobi

    -t, --to FORMAT                  Output format (required)
    -o, --output PATH                Output file (default: first input's name)
        --title TITLE                Book title (default: first heading, else file name)
        --author AUTHOR              Book author
        --language CODE              Language code (default: en)
        --css FILE                   Extra stylesheet; may be given several times
        --strict                     Treat warnings (missing images, stylesheets) as errors
    -h, --help                       Show this help
```

- The input format comes from the file extension (`.txt`, `.md`, `.html`). Any other extension is rejected.
- Inputs become chapters in the order you give them.
- The output defaults to the first input's name with the new extension, written to the current directory (`notes.md` → `notes.epub`).
- `--css` stylesheets are applied after the CSS found in the HTML inputs, so their rules win.

### Examples

```sh
# Single Markdown file → notes.epub
bookbind notes.md --to epub

# A web page with its images and CSS, plus your own stylesheet
bookbind article/index.html --to epub --css reader.css --output article.epub

# Several files → one Kindle-compatible book in Czech
bookbind 01-uvod.md 02-kapitola.md --to mobi --language cs --author "Jan Novák"

# Fail instead of warn when an image or stylesheet is missing
bookbind page.html --to epub --strict
```

### Exit codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Usage error: bad option, missing or unsupported input, unknown format |
| 2 | Conversion error: pandoc or Calibre failed, output not writable, or a warning under `--strict` |
| 3 | A required external tool is missing or too old |

Errors and warnings go to stderr as plain messages, without stack traces.

## How it works

```
input file ──Reader──▶ Chapter (HTML) ─┐
input file ──Reader──▶ Chapter (HTML) ─┼─▶ Book ──Writer──▶ .epub / .mobi
input file ──Reader──▶ Chapter (HTML) ─┘
```

Every reader produces HTML, because pandoc accepts only one `--from` format for all its inputs.

- **Text**: converted in Ruby. Blank lines separate paragraphs, and the text is HTML-escaped, so `*`, `#` and `_` stay literal.
- **Markdown**: converted with `pandoc -f markdown -t html`.
- **HTML**: parsed with Nokogiri. Linked stylesheets and inline `<style>` blocks are collected and passed to pandoc as `--css` files. Relative image paths are made absolute.

After reading, each chapter gets an `<h1>` if it lacks one, so pandoc starts a new chapter at every input file. The heading is derived from the file name.

The EPUB writer runs `pandoc --to epub3 --split-level=1 --toc`, which embeds the images and stylesheets. The MOBI writer builds the EPUB first, then runs `ebook-convert`. Intermediate files live in a temporary directory that is always removed afterwards.

## Known limitations

The integration specs in `spec/integration/pandoc_behaviour_spec.rb` verify these findings against pandoc 3.x.

**Styling**
- **`<p>` loses `class`, `id` and `style`.** Pandoc's paragraph has no place for attributes, so rules like `p.lead` or `#intro-para` stop applying. These attributes do survive on `div`, `span`, `section`, `img` and headings. A heading's `id` moves to the `<section>` pandoc wraps around it, and its class stays on the heading.
- **Inline `style=""`** follows the same pattern: it's kept on `div`, `span` and `img`, and dropped on `<p>`.
- **`url(...)` references inside CSS are not embedded.** Pandoc copies stylesheets verbatim, so background images and fonts that a stylesheet references are missing from the book.
- **Remote stylesheets** (`<link href="https://…">`) are skipped with a warning.
- **Stylesheet order:** all linked stylesheets come before all inline `<style>` blocks of a page, whatever their order in the source.

**Images**
- **Local images** with relative or absolute paths are embedded. Relative paths resolve against the HTML file's folder. Pandoc on its own would resolve them against its working directory, so `bookbind` rewrites them first.
- **A missing local image** produces a warning and is replaced by its alt text, so the book never contains a broken reference.
- **`data:` URIs** are embedded as image files.
- **Remote images (`http(s)://`)** are downloaded by pandoc at build time, so the build needs network access and the result depends on the remote server. If a download fails, pandoc warns, and the book keeps a broken image reference. Use `--strict` to fail instead.

**Other**
- **JavaScript is dropped**, along with everything else in `<head>`. The HTML `<title>` is not used as the book title; the first heading is.
- **Malformed HTML** is repaired by the parser, but formatting inside badly broken markup can be lost.
- **Links between chapters** (`<a href="other.html#x">`) are not rewritten and won't work in the book. If two inputs use the same explicit `id`, the second one's links may point to the first.
- **MOBI** is a legacy format. Amazon now prefers EPUB for Send to Kindle, so use MOBI only for older devices.

## Adding a format

Readers and writers register themselves, so a new format means adding one file and changing no existing class. Every file in `lib/bookbind/readers/` and `lib/bookbind/writers/` is loaded automatically. The registered block receives `Bookbind::Wiring`, which provides shared collaborators (`pandoc`, `calibre`, `normalizer`).

**A writer** responds to `extension`, `required_tools` and `write(book, scratch)`, and returns the path of the file it built inside `scratch`. For example, AZW3 through Calibre:

```ruby
# lib/bookbind/writers/azw3_writer.rb
module Bookbind
  class Azw3Writer
    def initialize(epub_writer:, calibre:)
      @epub_writer = epub_writer
      @calibre = calibre
    end

    def extension = "azw3"

    def required_tools = [@calibre.requirement]

    def write(book, scratch)
      epub = @epub_writer.write(book, scratch)
      scratch.path("book.azw3").tap { |out| @calibre.convert(epub, out) }
    end
  end
end

Bookbind::WRITERS.register("azw3") do |deps|
  Bookbind::Azw3Writer.new(epub_writer: Bookbind::EpubWriter.new(pandoc: deps.pandoc), calibre: deps.calibre)
end
```

**A reader** responds to `read(path, scratch)` and returns a `Bookbind::Chapter`. The usual approach is to produce HTML and hand it to the normaliser, which fixes image paths, collects CSS and ensures a heading:

```ruby
Bookbind::READERS.register(".rst") do |deps|
  Bookbind::RstReader.new(pandoc: deps.pandoc, normalizer: deps.normalizer)
end
```

New external tools are declared as an object that responds to `check(runner)` and raises `Bookbind::MissingToolError` (see `ExecutableRequirement`).

## Development

```sh
bundle exec rspec      # all specs
bundle exec rubocop    # style and Sandi Metz limits
```

- **Tool-dependent specs:** integration specs that need real tools are tagged `:requires_pandoc` or `:requires_calibre`, and are skipped when the tool isn't on `PATH`. Everything else runs without either tool.
- **Coverage:** written to `coverage/`.
- **Code limits** (enforced in `.rubocop.yml`): classes up to 100 lines, methods up to 5 lines, and at most 4 parameters, keyword arguments included. Don't add inline disables; refactor instead.
