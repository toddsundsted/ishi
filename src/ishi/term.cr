require "./base"

module Ishi
  # Terminal interface.
  #
  abstract class Term < Base
    # :nodoc:
    getter io : IO = STDOUT

    def initialize(@term : String, @io : IO = STDOUT)
      super()
    end

    def show(**options)
      term =
        (size = @canvas_size) ?
        "set term #{@term} size #{size[0]},#{size[1]}" :
        "set term #{@term}"
      if (rows = @rows) && (cols = @cols)
        Gnuplot.new([term], io: @io).show(@charts, rows, cols, **options)
      else
        Gnuplot.new([term], io: @io).show(@charts.first, **options)
      end
    end
  end
end
