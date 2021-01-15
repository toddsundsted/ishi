require "../src/*"
require "spectator"
require "yaml"

module Ishi
  class SpecHelper < Term
    def initialize
      super("dumb")
    end
  end

  class Gnuplot
    def run(commands : Enumerable(String))
      commands
    end
  end

  @@default = SpecHelper
end
