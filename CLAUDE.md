# bookbind

Ruby CLI that turns .txt/.md/.html files into .epub/.mobi by driving pandoc (≥ 3.0) and Calibre's `ebook-convert`. For people who want a quick ebook from their notes or web pages.

## How we work here
- Pipeline: Reader → `Chapter` (HTML) → `Book` → Writer. All readers output HTML, because pandoc takes one `--from` for all inputs.
- Formats self-register in `lib/bookbind/readers/*.rb` / `writers/*.rb` (`Bookbind::READERS` / `WRITERS`). `Bookbind::Wiring` is the composition root.
- Sandi Metz rules, enforced by `.rubocop.yml`: class ≤ 100 lines, method ≤ 5 lines, ≤ 4 params (kwargs count). Never raise limits or add inline disables — refactor.
- Test-first. Unit specs use doubles; integration specs tagged `:requires_pandoc` / `:requires_calibre` skip when the tool is missing.
- Keep green: `bundle exec rspec` and `bundle exec rubocop`.
- Gems: nokogiri, rspec, rubocop, simplecov, rubyzip. Ask before adding anything else.
- Commit after each slice; never push.
