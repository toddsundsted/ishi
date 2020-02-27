require "../src/*"
require "spectator"
require "yaml"

module Ishi
  private class SpecHelper < Base
    def show(**options)
      Gnuplot.new(["set term dumb"]).show(@chart, **options)
    end
  end

  class Gnuplot
    def run(commands : Enumerable(String))
      commands
    end
  end

  @@default = SpecHelper
end
