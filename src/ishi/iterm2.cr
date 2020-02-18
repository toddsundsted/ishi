require "../ishi"
require "iterm2"

module Ishi
  # Renders chart as image to the ITerm2 console.
  #
  class ITerm2 < Base
    def initialize
      @gnuplot = Gnuplot.new(["set term png"])
    end
  end

  class Gnuplot
    def show(**options)
      Iterm2.new.display(previous_def(), **options)
    end
  end

  @@default = ITerm2
end
