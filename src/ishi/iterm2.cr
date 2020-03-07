require "../ishi"
require "iterm2"

module Ishi
  # Renders chart as image to the ITerm2 console.
  #
  class ITerm2 < Base
    def show(**options)
      term =
        (size = @canvas_size) ?
        "set term pngcairo enhanced size #{size[0]},#{size[1]}" :
        "set term pngcairo enhanced"
      Gnuplot.new([term]).show(@chart, **options)
    end
  end

  class Gnuplot
    def show(chart, **options)
      Iterm2.new.display(previous_def(chart), **options)
    end
  end

  @@default = ITerm2
end
