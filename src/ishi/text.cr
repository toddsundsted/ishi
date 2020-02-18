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
      @gnuplot = Gnuplot.new(["set term dumb"])
      Ishi.io = io
    end
  end

  class Gnuplot
    def show
      previous_def().each_line do |line|
        Ishi.io.puts line
      end
    end
  end

  @@default = Text
end
