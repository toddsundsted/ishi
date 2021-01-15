require "../ishi"
require "iterm2"

module Ishi
  # Renders chart as image to the ITerm2 console.
  #
  class Iterm2 < Term
    def initialize(io : IO = STDOUT)
      super("pngcairo enhanced", io)
    end
  end

  class Gnuplot
    def show(chart, **options)
      ::Iterm2.new(@term.io).display(previous_def(chart), **options)
    end

    def show(chart, rows, cols, **options)
      ::Iterm2.new(@term.io).display(previous_def(chart, rows, cols), **options)
    end
  end

  @@default = Iterm2
end
