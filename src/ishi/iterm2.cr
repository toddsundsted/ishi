require "../ishi"
require "iterm2"

module Ishi
  # :nodoc:
  @@io : IO = STDOUT

  # :nodoc:
  def self.io
    @@io
  end

  # :nodoc:
  def self.io=(io)
    @@io = io
  end

  # Renders chart as image to the ITerm2 console.
  #
  class Iterm2 < Base
    def initialize(io : IO = STDOUT)
      Ishi.io = io
      super()
    end

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
      ::Iterm2.new(Ishi.io).display(previous_def(chart), **options)
    end

    def show(chart, rows, cols, **options)
      ::Iterm2.new(Ishi.io).display(previous_def(chart, rows, cols), **options)
    end
  end

  @@default = Iterm2
end
