require "../ishi"

module Ishi
  @@io : IO = STDOUT

  def self.io
    @@io
  end

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
      Gnuplot.new(["set term dumb"]).show(@chart, **options)
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
