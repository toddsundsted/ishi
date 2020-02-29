require "../ishi"
require "iterm2"

module Ishi
  # Renders chart as image to the ITerm2 console.
  #
  class ITerm2 < Base
    def show(**options)
      Gnuplot.new(["set term pngcairo enhanced"]).show(@chart, **options)
    end
  end

  class Gnuplot
    def show(chart, **options)
      Iterm2.new.display(previous_def(chart), **options)
    end
  end

  @@default = ITerm2
end
