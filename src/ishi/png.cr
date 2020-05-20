require "../ishi"

module Ishi
  # Renders chart as PNG.
  #
  class Png < Term
    def initialize(io : IO = STDOUT)
      super("pngcairo enhanced", io)
    end
  end

  class Gnuplot
    def show(chart)
      IO.copy(previous_def(chart), Png.io)
    end

    def show(chart, rows, cols)
      IO.copy(previous_def(chart, rows, cols), Png.io)
    end
  end

  @@default = Png
end
