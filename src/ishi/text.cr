require "../ishi"

module Ishi
  # Renders chart as text to the console.
  #
  class Text < Term
    def initialize(io : IO = STDOUT)
      super("dumb", io)
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

  @@default = Text
end
