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

  # Renders chart as text to the console.
  #
  class Text < Base
    def initialize(io : IO = STDOUT)
      Ishi.io = io
      super()
    end

    def show(**options)
      term =
        (size = @chart.canvas_size) ?
        "set term dumb size #{size[0]},#{size[1]}" :
        "set term dumb"
      Gnuplot.new([term]).show(@chart, **options)
    end
  end

  class Gnuplot
    def show(chart)
      previous_def(chart).each_line do |line|
        Ishi.io.puts line
      end
    end
  end

  @@default = Text
end
