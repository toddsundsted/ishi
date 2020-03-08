require "../ishi"

module Ishi
  @@io : IO = STDOUT

  # :nodoc:
  def self.io
    @@io
  end

  # :nodoc:
  def self.io=(io)
    @@io = io
  end

  # Renders chart as HTML to the console.
  #
  class Html < Base
    def initialize(io : IO = STDOUT)
      Ishi.io = io
      super()
    end

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
        Ishi.io.puts line
      end
    end

    def show(chart, rows, cols)
      previous_def(chart, rows, cols).each_line do |line|
        Ishi.io.puts line
      end
    end
  end

  @@default = Html
end
