# frozen_string_literal: true

module ToolAvailability
  def self.on_path?(command)
    ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).any? do |dir|
      File.executable?(File.join(dir, command))
    end
  end
end
