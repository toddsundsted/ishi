require "../ishi"

module Ishi
  # Renders chart as HTML to the console.
  #
  class Html < Term
    def show(**options)
      term =
        (size = @canvas_size) ?
        "set term canvas size #{size[0]},#{size[1]}" :
        "set term canvas"
      if (rows = @rows) && (cols = @cols)
        Gnuplot.new([term]).show(@charts, rows, cols, **options)
      else
        Gnuplot.new([term]).show(@charts.first, **options)
      end
    end
  end

  class Gnuplot
    def show(chart)
      previous_def(chart).each_line do |line|
        Term.io.puts line
      end
    end

    def show(chart, rows, cols)
      previous_def(chart, rows, cols).each_line do |line|
        Term.io.puts line
      end
    end
  end

  @@default = Html
end
