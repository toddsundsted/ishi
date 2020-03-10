require "../ishi"
require "iterm2"

module Ishi
  # Renders chart as image to the ITerm2 console.
  #
  class Iterm2 < Term
    def show(**options)
      term =
        (size = @canvas_size) ?
        "set term pngcairo enhanced size #{size[0]},#{size[1]}" :
        "set term pngcairo enhanced"
      if (rows = @rows) && (cols = @cols)
        Gnuplot.new([term]).show(@charts, rows, cols, **options)
      else
        Gnuplot.new([term]).show(@charts.first, **options)
      end
    end
  end

  class Gnuplot
    def show(chart, **options)
      ::Iterm2.new(Term.io).display(previous_def(chart), **options)
    end

    def show(chart, rows, cols, **options)
      ::Iterm2.new(Term.io).display(previous_def(chart, rows, cols), **options)
    end
  end

  @@default = Iterm2
end
