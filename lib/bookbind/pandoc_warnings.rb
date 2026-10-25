# frozen_string_literal: true

module Bookbind
  # Extracts pandoc's [WARNING] lines and drops the Haskell exception dumps behind them.
  class PandocWarnings
    WARNING = /^\[WARNING\] (.*)$/
    RESOURCE = /\ACould not fetch resource (.+?): Pandoc\w+.*\z/

    def self.parse(stderr)
      stderr.scan(WARNING).flatten.map { |line| line.sub(RESOURCE, 'could not fetch resource \1') }
    end
  end
end
