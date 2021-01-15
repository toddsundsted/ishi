require "../ishi"

module Ishi
  # Renders chart as HTML to the console.
  #
  class Html < Term
    def initialize(io : IO = STDOUT)
      super("canvas", io)
    end
  end

  class Gnuplot
    def show(chart)
      previous_def(chart).each_line do |line|
        @term.io.puts line
      end
    end

    def show(chart, rows, cols)
      previous_def(chart, rows, cols).each_line do |line|
        @term.io.puts line
      end
    end
  end

  @@default = Html
end
