require "../src/*"
require "spectator"
require "yaml"

module Ishi
  private class SpecHelper < Base
    def show(**options)
      term =
        (size = @canvas_size) ?
        "set term dumb size #{size[0]},#{size[1]}" :
        "set term dumb"
      if (rows = @rows) && (cols = @cols)
        Gnuplot.new([term]).show(@charts, rows, cols, **options)
      else
        Gnuplot.new([term]).show(@charts.first, **options)
      end
    end
  end

  class Gnuplot
    def run(commands : Enumerable(String))
      commands
    end
  end

  @@default = SpecHelper
end
