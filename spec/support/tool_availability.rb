# frozen_string_literal: true

module ToolAvailability
  def self.locate(command)
    ENV.fetch("PATH", "").split(File::PATH_SEPARATOR)
       .map { |dir| File.join(dir, command) }.find { |path| File.executable?(path) }
  end

  def self.on_path?(command) = !locate(command).nil?
end
