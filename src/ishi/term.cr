require "./base"

module Ishi
  # Terminal interface.
  #
  abstract class Term < Base
    # :nodoc:
    @@io : IO = STDOUT

    def self.io
      @@io
    end

    def initialize(@@io : IO = STDOUT)
      super()
    end
  end
end
