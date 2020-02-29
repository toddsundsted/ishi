# Graph plotting package with a small API powered by gnuplot.
#
# See `Base` for documentation on supported methods.
#
module Ishi
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}

  class Base
    # :nodoc:
    def initialize
      @chart = Ishi::Gnuplot::Chart.new
    end

    # Plots a mathematical expression.
    #
    #     plot("sin(x) * cos(x)")
    #     plot("3.5 * x + 1.5")
    #
    # For information on gnuplot mathematical expressions, see:
    # [Expressions](http://www.gnuplot.info/docs_5.2/Gnuplot_5.2.pdf#section*.27).
    #
    # *title* is the title of the plot. *style* is the drawing
    # style. Supported values include `:lines` and `:points`.
    #
    def plot(expression : String, title : String? = nil, style : Symbol? = nil, **options)
      @chart.plot(Ishi::Gnuplot::PlotExp.new(expression, title, style, **options))
      self
    end

    # Plots `y` using `x` ranging from `0` to `N-1`.
    #
    # *title* is the title of the plot. *style* is the drawing
    # style. Supported values include `:boxes`, `:lines` and
    # `:points`.
    #
    def plot(ydata : Indexable(Y), title : String? = nil, style : Symbol = :lines, **options) forall Y
      {% raise "data must be numeric" unless Y < Number %}
      @chart.plot(Ishi::Gnuplot::PlotY.new(ydata, title, style, **options))
      self
    end

    # Plots `x` and `y`.
    #
    # *title* is the title of the plot. *style* is the drawing
    # style. Supported values include `:boxes`, `:lines` and
    # `:points`.
    #
    def plot(xdata : Indexable(X), ydata : Indexable(Y), title : String? = nil, style : Symbol = :lines, **options) forall X, Y
      {% raise "data must be numeric" unless X < Number && Y < Number %}
      @chart.plot(Ishi::Gnuplot::PlotXY.new(xdata, ydata, title, style, **options))
      self
    end

    # Plots `x`, `y` and `z`.
    #
    # *title* is the title of the plot. *style* is the drawing
    # style. Supported values include `:boxes`, `:lines` and
    # `:points`.
    #
    def plot(xdata : Indexable(X), ydata : Indexable(Y), zdata : Indexable(Z), title : String? = nil, style : Symbol = :points, **options) forall X, Y, Z
      {% raise "data must be numeric" unless X < Number && Y < Number && Z < Number %}
      @chart.plot(Ishi::Gnuplot::PlotXYZ.new(xdata, ydata, zdata, title, style, **options))
      self
    end

    # Sets the label of the `x` axis.
    #
    def xlabel(xlabel : String)
      @chart.xlabel(xlabel)
      self
    end

    # Sets the label of the `y` axis.
    #
    def ylabel(ylabel : String)
      @chart.ylabel(ylabel)
      self
    end

    # Sets the label of the `z` axis.
    #
    def zlabel(zlabel : String)
      @chart.zlabel(zlabel)
      self
    end

    # Sets the range of the `x` axis.
    #
    def xrange(xrange : Range(Float64, Float64) | Range(Int32, Int32))
      @chart.xrange(xrange)
      self
    end

    # Sets the range of the `y` axis.
    #
    def yrange(yrange : Range(Float64, Float64) | Range(Int32, Int32))
      @chart.yrange(yrange)
      self
    end

    # Sets the range of the `z` axis.
    #
    def zrange(zrange : Range(Float64, Float64) | Range(Int32, Int32))
      @chart.zrange(zrange)
      self
    end

    # Shows the chart.
    #
    def show(**options)
      Gnuplot.new(["set term qt persist"]).show(@chart, **options)
    end
  end

  @@default = Base

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

require "./ishi/gnuplot"
