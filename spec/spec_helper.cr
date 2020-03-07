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
      Gnuplot.new([term]).show(@chart, **options)
    end
  end

  class Gnuplot
    def run(commands : Enumerable(String))
      commands
    end
  end

  @@default = SpecHelper
end
