# frozen_string_literal: true

module Bookbind
  CommandResult = Data.define(:stdout, :stderr, :success) do
    alias_method :success?, :success
  end
end
