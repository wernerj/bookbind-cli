# frozen_string_literal: true

module Bookbind
  # Verifies external tools before any work starts. Requirements respond to #check(runner).
  class ToolCheck
    def initialize(runner:, baseline: [PandocRequirement.new])
      @runner = runner
      @baseline = baseline
    end

    def verify(requirements)
      (@baseline + requirements).each { |requirement| requirement.check(@runner) }
    end
  end
end
