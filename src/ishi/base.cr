module Ishi
  # Supported methods.
  #
  abstract class Base
    # :nodoc:
    class Proxy < Base
      def initialize
        super
      end

      def initialize(chart : Ishi::Gnuplot::Chart)
        @charts = [chart]
      end

      def charts(rows : Int32, cols : Int32)
        raise NotImplementedError.new("not supported on proxies")
      end

      def show(**options)
        raise NotImplementedError.new("not supported on proxies")
      end
    end

    # :nodoc:
    def initialize
      @charts = [Ishi::Gnuplot::Chart.new]
    end

    # Changes the number of charts in the figure.
    #
    # By default a figure has one chart. This call changes the number
    # of charts in the figure. The original chart is preserved and
    # becomes the chart in the first row, first column of the new
    # layout.
    #
    # Returns the charts.
    #
    #     figure = Ishi.new
    #     charts = figure.charts(2, 2)
    #     charts[0].plot([1, 2, 3, 4])
    #     charts[1].plot([2, 3, 4, 1])
    #       ...
    #     figure.show
    #
    def charts(rows : Int32, cols : Int32)
      raise ArgumentError.new("rows must be greater than zero") if rows < 1
      raise ArgumentError.new("cols must be greater than zero") if cols < 1
      if (delta = rows * cols - @charts.size) > 0
        delta.times { @charts << Ishi::Gnuplot::Chart.new }
      elsif delta < 0
        @charts = @charts[0..delta - 1]
      end
      @rows = rows
      @cols = cols
      @charts.map do |chart|
        Proxy.new(chart)
      end
    end

    # Changes the number of charts in the figure.
    #
    # By default a figure has one chart. This call changes the number
    # of charts in the figure. The original chart is preserved and
    # becomes the chart in the first row, first column of the new
    # layout.
    #
    # Yields each chart as the default receiver of the supplied
    # block. Block arguments are *i* (the i-th chart in the figure),
    # *row* and *col* (the row and column of the chart).
    #
    #     figure = Ishi.new
    #     figure.charts(2, 2) do |i|
    #       plot([1, 2, 3, 4].rotate(i))
    #         ...
    #     end
    #     figure.show
    #
    def charts(rows : Int32, cols : Int32)
      temp = charts(rows, cols)
      i = 0
      rows.times do |r|
        cols.times do |c|
          with temp[i] yield i, r, c
          i += 1
        end
      end
    end

    # Returns the number of charts in the figure.
    #
    def size
      @charts.size
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
      @charts.first.plot(Ishi::Gnuplot::PlotExp.new(expression, title, style, format, **options))
      self
    end

    # compatible extensions
    private SUPPORTED = [
      "MXNet::NDArray"
    ]

    # Plots `y` using `x` ranging from `0` to `N-1`.
    #
    # *title* is the title of the plot. *style* is the drawing
    # style. Supported styles include `:boxes`, `:lines`, `:points`,
    # `:linespoints` and `:dots`.
    #
    def plot(ydata : Indexable(Y), format : String? = nil, *, title : String? = nil, style : Symbol = :lines, **options) forall Y
      {% raise "type must be numeric" unless [Y].all? { |a| SUPPORTED.includes?(a.stringify) || a < Number } %}
      @charts.first.plot(Ishi::Gnuplot::PlotY.new(ydata, title, style, format, **options))
      self
    end

    # Plots `x` and `y`.
    #
    # *title* is the title of the plot. *style* is the drawing
    # style. Supported styles include `:boxes`, `:lines`, `:points`,
    # `:linespoints` and `:dots`.
    #
    def plot(xdata : Indexable(M), ydata : Indexable(N), format : String? = nil, *, title : String? = nil, style : Symbol = :points, **options) forall M, N
      {% raise "type must be numeric" unless [M, N].all? { |a| SUPPORTED.includes?(a.stringify) || a < Number } %}
      @charts.first.plot(Ishi::Gnuplot::PlotXY.new(xdata, ydata, title, style, format, **options))
      self
    end

    # Plots `x`, `y` and `z`.
    #
    # *title* is the title of the plot. *style* is the drawing
    # style. Supported styles include `:surface`, `:circles`,
    # `:lines`, `:points` and `:dots`.
    #
    def plot(xdata : Indexable(T), ydata : Indexable(U), zdata : Indexable(V), format : String? = nil, *, title : String? = nil, style : Symbol = :points, **options) forall T, U, V
      {% raise "type must be numeric" unless [T, U, V].all? { |a| SUPPORTED.includes?(a.stringify) || a < Number } %}
      @charts.first.plot(Ishi::Gnuplot::PlotXYZ.new(xdata, ydata, zdata, title, style, format, **options))
      self
    end

    # Scatter plots `x` and `y`.
    #
    # *title* is the title of the plot.
    #
    def scatter(xdata : Indexable(M), ydata : Indexable(N), format : String? = nil, *, title : String? = nil, style : Symbol = :dots, **options) forall M, N
      {% raise "type must be numeric" unless [M, N].all? { |a| SUPPORTED.includes?(a.stringify) || a < Number } %}
      @charts.first.plot(Ishi::Gnuplot::PlotXY.new(xdata, ydata, title, style, format, **options))
      self
    end

    # Scatter plots `x`, `y` and `z`.
    #
    # *title* is the title of the plot.
    #
    def scatter(xdata : Indexable(T), ydata : Indexable(U), zdata : Indexable(V), format : String? = nil, *, title : String? = nil, style : Symbol = :dots, **options) forall T, U, V
      {% raise "type must be numeric" unless [T, U, V].all? { |a| SUPPORTED.includes?(a.stringify) || a < Number } %}
      @charts.first.plot(Ishi::Gnuplot::PlotXYZ.new(xdata, ydata, zdata, title, style, format, **options))
      self
    end

    # Displays an image.
    #
    # *data* is scalar image data.
    #
    # Data is visualized using a colormap.
    #
    def imshow(data : Indexable(Indexable(D)), **options) forall D
      {% raise "type must be numeric" unless [D].all? { |a| SUPPORTED.includes?(a.stringify) || a < Number } %}
      @charts.first.plot(Ishi::Gnuplot::Plot2D.new(data, **options.merge({style: :image})))
      self
    end

    # Sets the label of the `x` axis.
    #
    def xlabel(xlabel : String)
      @charts.first.xlabel(xlabel)
      self
    end

    # Sets the label of the `y` axis.
    #
    def ylabel(ylabel : String)
      @charts.first.ylabel(ylabel)
      self
    end

    # Sets the label of the `z` axis.
    #
    def zlabel(zlabel : String)
      @charts.first.zlabel(zlabel)
      self
    end

    # Sets the range of the `x` axis.
    #
    def xrange(xrange : Range(Float64, Float64) | Range(Int32, Int32))
      @charts.first.xrange(xrange)
      self
    end

    # Sets the range of the `y` axis.
    #
    def yrange(yrange : Range(Float64, Float64) | Range(Int32, Int32))
      @charts.first.yrange(yrange)
      self
    end

    # Sets the range of the `z` axis.
    #
    def zrange(zrange : Range(Float64, Float64) | Range(Int32, Int32))
      @charts.first.zrange(zrange)
      self
    end

    # Sets the default width of boxes in the boxes, boxerrorbars, candlesticks
    # and histograms styles.
    #
    # For information on setting the box width, see:
    # [Boxwidth](http://www.gnuplot.info/docs_5.2/Gnuplot_5.2.pdf#section*.232).
    #
    def boxwidth(boxwidth : Float64)
      @charts.first.boxwidth(boxwidth)
      self
    end

    # Sets non-numeric labels on the x-axis.
    #
    # This translates to `set xtics ({"<label>"} <pos> {<level>} {,{"<label>"}...})`
    #
    # see: [Xtics list](http://www.gnuplot.info/docs_5.2/Gnuplot_5.2.pdf#section*.404)
    #
    # Example:
    # ```crystal
    # plot(x, y).xtics({1.0 => "Jan", 6.0 => "Jun", 12.0 => "Dec"})
    # ```
    #
    def xtics(xtics : Hash(Float64, String))
      @charts.first.xtics(xtics)
      self
    end

    # Sets the viewing angle for 3D charts.
    #
    # For information on setting the viewing angle, see:
    # [View](http://www.gnuplot.info/docs_5.2/Gnuplot_5.2.pdf#section*.385).
    #
    def view(xrot : Float64, zrot : Float64)
      @charts.first.view(xrot, zrot)
      self
    end

    # :ditto:
    def view(xrot : Int32, zrot : Int32)
      @charts.first.view(xrot, zrot)
      self
    end

    # Sets the size of the terminal canvas.
    #
    def canvas_size(width : Float64, height : Float64)
      @canvas_size = {width, height}
      self
    end

    # :ditto:
    def canvas_size(width : Int32, height : Int32)
      @canvas_size = {width, height}
      self
    end

    # Sets the margin.
    #
    # For information on setting/unsetting the margin, see:
    # [Margin](http://www.gnuplot.info/docs_5.2/Gnuplot_5.2.pdf#section*.291).
    #
    def margin(
         left : Float64 | Bool = false, right : Float64 | Bool = false,
         top : Float64 | Bool = false, bottom : Float64 | Bool = false
       )
      @charts.first.margin(left, right, top, bottom)
      self
    end

    # :ditto:
    def margin(
         left : Int32 | Bool = false, right : Int32 | Bool = false,
         top : Int32 | Bool = false, bottom : Int32 | Bool = false
       )
      @charts.first.margin(left, right, top, bottom)
      self
    end

    {% begin %}
      # Sets the palette.
      #
      # *name* is `:gray` or one of the available color palettes:
      # {% palettes = Ishi::Gnuplot::PALETTES.keys.sort.map { |k| "`#{k.symbolize}`" } %} {{palettes[0..-2].join(", ").id}} or {{palettes[-1].id}}
      #
      # Optionally, shows/hides the chart colorbox based on the value
      # of *colorbox*.
      #
      def palette(name : Symbol, colorbox : Bool = true)
        @charts.first.palette(name, colorbox)
        self
      end
    {% end %}

    # Shows/hides the chart colorbox.
    #
    # For information on setting/unsetting the colorbox, see:
    # [Colorbox](http://www.gnuplot.info/docs_5.2/Gnuplot_5.2.pdf#section*.240).
    #
    def show_colorbox(show : Bool)
      @charts.first.show_colorbox(show)
      self
    end

    # Shows/hides the chart border.
    #
    # For information on setting/unsetting the border, see:
    # [Border](http://www.gnuplot.info/docs_5.2/Gnuplot_5.2.pdf#section*.231).
    #
    def show_border(show : Bool)
      @charts.first.show_border(show)
      self
    end

    # Shows/hides the chart xtics.
    #
    # For information on setting/unsetting the xtics, see:
    # [Xtics](http://www.gnuplot.info/docs_5.2/Gnuplot_5.2.pdf#section*.402).
    #
    def show_xtics(show : Bool)
      @charts.first.show_xtics(show)
      self
    end

    # Shows/hides the chart ytics.
    #
    # For information on setting/unsetting the ytics, see:
    # [Ytics](http://www.gnuplot.info/docs_5.2/Gnuplot_5.2.pdf#section*.423).
    #
    def show_ytics(show : Bool)
      @charts.first.show_ytics(show)
      self
    end

    # Shows/hides the chart key.
    #
    # For information on setting/unsetting the key, see:
    # [Key](http://www.gnuplot.info/docs_5.2/Gnuplot_5.2.pdf#section*.272).
    #
    def show_key(show : Bool)
      @charts.first.show_key(show)
      self
    end

    # Shows the chart(s).
    #
    abstract def show(**options)
  end
end
