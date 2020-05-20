require "./base"

module Ishi
  # Terminal interface.
  #
  abstract class Term < Base
    # :nodoc:
    @@io : IO = STDOUT

    def self.io
      @@io
    end

    def self.io=(io)
      @@io = io
    end

    def initialize(@term : String, @@io : IO = STDOUT)
      super()
    end

    def show(**options)
      term =
        (size = @canvas_size) ?
        "set term #{@term} size #{size[0]},#{size[1]}" :
        "set term #{@term}"
      if (rows = @rows) && (cols = @cols)
        Gnuplot.new([term]).show(@charts, rows, cols, **options)
      else
        Gnuplot.new([term]).show(@charts.first, **options)
      end
    end
  end
end
