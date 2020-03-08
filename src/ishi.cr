require "./ishi/gnuplot"
require "./ishi/base"

# Graph plotting package with a small API powered by gnuplot.
#
# See `Base` for documentation on supported methods.
#
module Ishi
  # :nodoc:
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}

  # :nodoc:
  class Term < Base
    def show(**options)
      term =
        (size = @canvas_size) ?
        "set term qt persist size #{size[0]},#{size[1]}" :
        "set term qt persist"
      if (rows = @rows) && (cols = @cols)
        Gnuplot.new([term]).show(@charts, rows, cols, **options)
      else
        Gnuplot.new([term]).show(@charts.first, **options)
      end
    end
  end

  # :nodoc:
  @@default = Term

  # Creates a new instance.
  #
  # ```
  # ishi = Ishi.new
  # ishi.plot([1, 2, 3, 4])
  # ishi.show
  # ```
  #
  def self.new
    @@default.new
  end

  # Creates a new instance.
  #
  # Yields to the supplied block with the new instance as the implicit
  # receiver. Automatically invokes `#show` before returning.  Any
  # *options* are passed to `#show`.
  #
  # ```
  # Ishi.new do
  #   plot([1, 2, 3, 4])
  # end
  # ```
  #
  def self.new(**options)
    @@default.new.tap do |instance|
      with instance yield
      instance.show(**options)
    end
  end
end
