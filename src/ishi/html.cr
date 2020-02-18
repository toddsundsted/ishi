require "../ishi"

module Ishi
  @@io : IO = STDOUT

  def self.io
    @@io
  end

  def self.io=(io)
    @@io = io
  end

  # Renders chart as HTML to the console.
  #
  class Html < Base
    def initialize(io : IO = STDOUT)
      @gnuplot = Gnuplot.new(["set term canvas"])
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

  @@default = Html
end
