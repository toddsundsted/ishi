require "../src/*"
require "spectator"
require "yaml"

module Ishi
  private class SpecHelper < Base
    def initialize
      @gnuplot = Gnuplot.new(["set term dumb"])
    end
  end

  class Gnuplot
    def run(commands : Enumerable(String))
      commands
    end
  end

  @@default = SpecHelper
end
