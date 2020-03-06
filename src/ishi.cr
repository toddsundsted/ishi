require "./ishi/gnuplot"

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
    # style. Supported styles include `:lines` and `:points`.
    #
    def plot(expression : String, format : String? = nil, *, title : String? = nil, style : Symbol? = nil, **options)
      @chart.plot(Ishi::Gnuplot::PlotExp.new(expression, title, style, format, **options))
      self
    end

    # Plots `y` using `x` ranging from `0` to `N-1`.
    #
    # *title* is the title of the plot. *style* is the drawing
    # style. Supported styles include `:boxes`, `:lines`, `:points`,
    # `:linespoints` and `:dots`.
    #
    def plot(ydata : Indexable(Y), format : String? = nil, *, title : String? = nil, style : Symbol = :lines, **options) forall Y
      {% raise "data must be numeric" unless Y < Number %}
      @chart.plot(Ishi::Gnuplot::PlotY.new(ydata, title, style, format, **options))
      self
    end

    # Plots `x` and `y`.
    #
    # *title* is the title of the plot. *style* is the drawing
    # style. Supported styles include `:boxes`, `:lines`, `:points`,
    # `:linespoints` and `:dots`.
    #
    def plot(xdata : Indexable(M), ydata : Indexable(N), format : String? = nil, *, title : String? = nil, style : Symbol = :points, **options) forall M, N
      {% raise "data must be numeric" unless M < Number && N < Number %}
      @chart.plot(Ishi::Gnuplot::PlotXY.new(xdata, ydata, title, style, format, **options))
      self
    end

    # Plots `x`, `y` and `z`.
    #
    # *title* is the title of the plot. *style* is the drawing
    # style. Supported styles include `:surface`, `:circles`,
    # `:lines`, `:points` and `:dots`.
    #
    def plot(xdata : Indexable(T), ydata : Indexable(U), zdata : Indexable(V), format : String? = nil, *, title : String? = nil, style : Symbol = :points, **options) forall T, U, V
      {% raise "data must be numeric" unless T < Number && U < Number && V < Number %}
      @chart.plot(Ishi::Gnuplot::PlotXYZ.new(xdata, ydata, zdata, title, style, format, **options))
      self
    end

    # Scatter plots `x` and `y`.
    #
    # *title* is the title of the plot.
    #
    def scatter(xdata : Indexable(M), ydata : Indexable(N), format : String? = nil, *, title : String? = nil, style : Symbol = :dots, **options) forall M, N
      {% raise "data must be numeric" unless M < Number && N < Number %}
      @chart.plot(Ishi::Gnuplot::PlotXY.new(xdata, ydata, title, style, format, **options))
      self
    end

    # Scatter plots `x`, `y` and `z`.
    #
    # *title* is the title of the plot.
    #
    def scatter(xdata : Indexable(T), ydata : Indexable(U), zdata : Indexable(V), format : String? = nil, *, title : String? = nil, style : Symbol = :dots, **options) forall T, U, V
      {% raise "data must be numeric" unless T < Number && U < Number && V < Number %}
      @chart.plot(Ishi::Gnuplot::PlotXYZ.new(xdata, ydata, zdata, title, style, format, **options))
      self
    end

    # Displays an image.
    #
    # *data* is scalar image data.
    #
    # Data is visualized using a colormap.
    #
    def imshow(data : Indexable(Indexable(D)), **options) forall D
      {% raise "data must be numeric" unless D < Number %}
      @chart.plot(Ishi::Gnuplot::Plot2D.new(data, **options.merge({style: :image})))
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

    # Sets the viewing angle for 3D charts.
    #
    # For information on setting the viewing angle, see:
    # [View](http://www.gnuplot.info/docs_5.2/Gnuplot_5.2.pdf#section*.385).
    #
    def view(xrot : Float64, zrot : Float64)
      @chart.view(xrot, zrot)
      self
    end

    # :ditto:
    def view(xrot : Int32, zrot : Int32)
      @chart.view(xrot, zrot)
      self
    end

    # Sets the size of the chart canvas.
    #
    def canvas_size(x : Float64, y : Float64)
      @chart.canvas_size(x, y)
      self
    end

    # :ditto:
    def canvas_size(x : Int32, y : Int32)
      @chart.canvas_size(x, y)
      self
    end

    {% begin %}
      # Sets the palette.
      #
      # *name* is `:gray` or one of the available color palettes:
      # {% palettes = Ishi::Gnuplot::PALETTES.keys.sort.map { |k| "`#{k.symbolize}`" } %} {{palettes[0..-2].join(", ").id}} or {{palettes[-1].id}}
      #
      def palette(name : Symbol)
        @chart.palette(name)
        self
      end
    {% end %}

    # Shows/hides the chart colorbox.
    #
    # For information on setting/unsetting the colorbox, see:
    # [Colorbox](http://www.gnuplot.info/docs_5.2/Gnuplot_5.2.pdf#section*.240).
    #
    def show_colorbox(show : Bool)
      @chart.show_colorbox(show)
      self
    end

    # Shows/hides the chart border.
    #
    # For information on setting/unsetting the border, see:
    # [Border](http://www.gnuplot.info/docs_5.2/Gnuplot_5.2.pdf#section*.231).
    #
    def show_border(show : Bool)
      @chart.show_border(show)
      self
    end

    # Shows/hides the chart xtics.
    #
    # For information on setting/unsetting the xtics, see:
    # [Xtics](http://www.gnuplot.info/docs_5.2/Gnuplot_5.2.pdf#section*.402).
    #
    def show_xtics(show : Bool)
      @chart.show_xtics(show)
      self
    end

    # Shows/hides the chart ytics.
    #
    # For information on setting/unsetting the ytics, see:
    # [Ytics](http://www.gnuplot.info/docs_5.2/Gnuplot_5.2.pdf#section*.423).
    #
    def show_ytics(show : Bool)
      @chart.show_ytics(show)
      self
    end

    # Shows/hides the chart key.
    #
    # For information on setting/unsetting the key, see:
    # [Key](http://www.gnuplot.info/docs_5.2/Gnuplot_5.2.pdf#section*.272).
    #
    def show_key(show : Bool)
      @chart.show_key(show)
      self
    end

    # Shows the chart.
    #
    def show(**options)
      term =
        (size = @chart.canvas_size) ?
        "set term qt persist size #{size[0]},#{size[1]}" :
        "set term qt persist"
      Gnuplot.new([term]).show(@chart, **options)
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
