module Ishi
  # Gnuplot rendering engine.
  #
  # Requires "gnuplot" be installed and available.
  #
  class Gnuplot
    # A chart is a collection of plots and related metadata.
    #
    class Chart
      # Sets the label of the `x` axis.
      #
      def xlabel(@xlabel : String)
        self
      end

      # Sets the label of the `y` axis.
      #
      def ylabel(@ylabel : String)
        self
      end

      # Sets the label of the `z` axis.
      #
      def zlabel(@zlabel : String)
        self
      end

      getter xlabel, ylabel, zlabel

      # Sets the range of the `x` axis.
      #
      def xrange(@xrange : Range(Float64, Float64) | Range(Int32, Int32))
        self
      end

      # Sets the range of the `y` axis.
      #
      def yrange(@yrange : Range(Float64, Float64) | Range(Int32, Int32))
        self
      end

      # Sets the range of the `z` axis.
      #
      def zrange(@zrange : Range(Float64, Float64) | Range(Int32, Int32))
        self
      end

      getter xrange, yrange, zrange

      # Sets the viewing angle for 3D charts.
      #
      def view(xrot : Float64, zrot : Float64)
        @view = {xrot, zrot}
        self
      end

      # :ditto:
      def view(xrot : Int32, zrot : Int32)
        @view = {xrot, zrot}
        self
      end

      getter view

      # Sets the palette.
      #
      def palette(@palette_name : Symbol)
        self
      end

      getter :palette_name

      # Shows/hides the chart colorbox.
      #
      def show_colorbox(@show_colorbox : Bool)
        self
      end

      getter show_colorbox

      # Shows/hides the chart border.
      #
      def show_border(@show_border : Bool)
        self
      end

      getter show_border

      # Shows/hides the chart xtics.
      #
      def show_xtics(@show_xtics : Bool)
        self
      end

      getter show_xtics

      # Shows/hides the chart ytics.
      #
      def show_ytics(@show_ytics : Bool)
        self
      end

      getter show_ytics

      @plots = [] of Plot

      getter plots

      # Adds a plot to the chart.
      #
      def plot(plot)
        plots << plot
        self
      end

      # Returns the number of plots.
      #
      def size
        @plots.size
      end

      # Clears the chart.
      #
      def clear
        @plots.clear
        @xlabel = @ylabel = @zlabel = nil
        @xrange = @yrange = @zrange = nil
      end

      # Returns the dimensionality of the chart.
      #
      # All plots in a chart must have the same dimensionality (it's not
      # currently possible to plot 2D and 3D data simultaneously).
      #
      def dim
        unless @plots.empty?
          return 2 if @plots.all? { |plot| plot.dim == 2 }
          return 3 if @plots.all? { |plot| plot.dim == 3 }
          raise "all plots in a chart must have the same dimensionality"
        end
        raise "the chart is empty"
      end

      def dim?
        dim
      rescue
        nil
      end
    end

    abstract class Plot
      abstract def inst
      abstract def data
      abstract def dim

      @@styles = [] of Symbol

      @title : String? = nil
      @style : Symbol | String | Nil = nil
      @format : String? = nil
      @dashtype : Array(Int32) | Int32 | String | Nil = nil
      @linecolor : String? = nil
      @linewidth : Int32 | Float64 | Nil = nil
      @linestyle : Int32? = nil
      @pointsize : Int32 | Float64 | Nil = nil
      @pointtype : Int32 | String | Nil = nil

      def initialize(options = nil)
        check_style
        expand_abbreviations(options) if options
        parse_format
        make_style
      end

      private def check_style
        if @style
          unless @@styles.includes?(@style)
            raise ArgumentError.new("invalid style: #{@style.inspect}")
          end
        end
      end

      private def expand_abbreviations(options)
        @dashtype ||= options[:dt]?
        @linecolor ||= options[:lc]?
        @linewidth ||= options[:lw]?
        @linestyle ||= options[:ls]?
        @pointsize ||= options[:ps]?
        @pointtype ||= options[:pt]?
      end

      private COLOR_MAP = {
        "b" => "blue",
        "g" => "green",
        "r" => "red",
        "c" => "cyan",
        "m" => "magenta",
        "y" => "yellow",
        "k" => "black",
        "w" => "white"
      }

      private POINT_TYPE_MAP = {
        "." => 0,
        "+" => 1,
        "x" => 2,
        "*" => 3,
        "s" => 5,
        "o" => 7,
        "^" => 9,
        "v" => 11,
        "d" => 13
      }

      private DASH_TYPE_MAP = {
        "-" => 1,
        "--" => 2,
        "!" => 9,
        ":" => 3
      }

      private def parse_format
        if format = @format
          unless @linecolor
            if format =~ /^[A-Z]{3,}$/i
              @linecolor = format
              return
            elsif format =~ /^#([0-9A-F]{2}){3,4}$/i
              @linecolor = format
              return
            elsif !(m = format.split(//) & COLOR_MAP.keys).empty?
              raise ArgumentError.new("ambiguous color: #{m.join}") if m.size > 1
              @linecolor = COLOR_MAP[m.first]
              format = format.gsub(m.first, "")
            end
          end
          unless @pointtype
            if !(m = format.split(//) & POINT_TYPE_MAP.keys).empty?
              raise ArgumentError.new("ambiguous point type: #{m.join}") if m.size > 1
              @pointtype = POINT_TYPE_MAP[m.first]
              format = format.gsub(m.first, "")
            end
          end
          unless @dashtype
            if DASH_TYPE_MAP.keys.includes?(format)
              @dashtype = DASH_TYPE_MAP[format]
              format = ""
            end
          end
          unless format.empty?
            raise ArgumentError.new("invalid format: #{format}")
          end
        end
      end

      private def make_style
        @style = _style
        @style = @style ? "with #{@style}" : nil
        if @dashtype || @linecolor || @linewidth || @linestyle || @pointsize || @pointtype
          @style = String.build do |io|
            io << @style || ""
            io << " dt #{_dashtype}" if @dashtype
            io << " lc #{_linecolor}" if @linecolor
            io << " lw #{@linewidth}" if @linewidth
            io << " ls #{@linestyle}" if @linestyle
            io << " ps #{@pointsize}" if @pointsize
            io << " pt #{_pointtype}" if @pointtype
          end
        end
      end

      private def _style
        if @style.nil? && (@pointsize || @pointtype)
          :linespoints
        elsif @style == :lines && (@pointsize || @pointtype)
          :linespoints
        elsif @style == :points && (@dashtype || @linewidth)
          :linespoints
        else
          @style
        end
      end

      private def _dashtype
        case (dashtype = @dashtype)
        when Array
          "(#{dashtype.join(",")})"
        when String
          "\"#{dashtype}\""
        else
          dashtype
        end
      end

      private def _linecolor
        "rgb \"#{@linecolor}\""
      end

      private def _pointtype
        case (pointtype = @pointtype)
        when String
          POINT_TYPE_MAP[pointtype]
        else
          pointtype
        end
      end
    end

    class PlotExp < Plot
      @@styles = [:lines, :points]

      def initialize(@expression : String,
                     @title : String? = nil, @style : Symbol | String | Nil = nil,
                     @format : String? = nil,
                     @dashtype : Array(Int32) | Int32 | String | Nil = nil,
                     @linecolor : String? = nil,
                     @linewidth : Int32 | Float64 | Nil = nil,
                     @linestyle : Int32? = nil,
                     @pointsize : Int32 | Float64 | Nil = nil,
                     @pointtype : Int32 | String | Nil = nil,
                     **options
                    )
        super(options)
      end

      def inst
        String.build do |io|
          io << "#{@expression}"
          io << " title '#{@title}'" if @title
          io << " #{@style}" if @style
        end
      end

      def data
        [] of String
      end

      def dim
      end
    end

    class PlotY(Y) < Plot
      @@styles = [:boxes, :lines, :points, :linespoints, :dots]

      def initialize(@ydata : Indexable(Y),
                     @title : String? = nil, @style : Symbol | String | Nil = nil,
                     @format : String? = nil,
                     @dashtype : Array(Int32) | Int32 | String | Nil = nil,
                     @linecolor : String? = nil,
                     @linewidth : Int32 | Float64 | Nil = nil,
                     @linestyle : Int32? = nil,
                     @pointsize : Int32 | Float64 | Nil = nil,
                     @pointtype : Int32 | String | Nil = nil,
                     **options
                    )
        super(options)
      end

      def inst
        String.build do |io|
          io << "'-'"
          io << " title '#{@title}'" if @title
          io << " #{@style}" if @style
        end
      end

      def data
        Array(String).new.tap do |arr|
          @ydata.each_with_index do |num, i|
            arr << "#{i} #{num}"
          end
          arr << "e"
        end
      end

      def dim
        2
      end
    end

    class PlotXY(X, Y) < Plot
      @@styles = [:boxes, :lines, :points, :linespoints, :dots]

      def initialize(@xdata : Indexable(X), @ydata : Indexable(Y),
                     @title : String? = nil, @style : Symbol | String | Nil = nil,
                     @format : String? = nil,
                     @dashtype : Array(Int32) | Int32 | String | Nil = nil,
                     @linecolor : String? = nil,
                     @linewidth : Int32 | Float64 | Nil = nil,
                     @linestyle : Int32? = nil,
                     @pointsize : Int32 | Float64 | Nil = nil,
                     @pointtype : Int32 | String | Nil = nil,
                     **options
                    )
        super(options)
      end

      def inst
        String.build do |io|
          io << "'-'"
          io << " title '#{@title}'" if @title
          io << " #{@style}" if @style
        end
      end

      def data
        Array(String).new.tap do |arr|
          @xdata.zip(@ydata).each do |x, y|
            arr << "#{x} #{y}"
          end
          arr << "e"
        end
      end

      def dim
        2
      end
    end

    class PlotXYZ(X, Y, Z) < Plot
      @@styles = [:circles, :surface, :lines, :points, :dots]

      def initialize(@xdata : Indexable(X), @ydata : Indexable(Y), @zdata : Indexable(Z),
                     @title : String? = nil, @style : Symbol | String | Nil = nil,
                     @format : String? = nil,
                     @dashtype : Array(Int32) | Int32 | String | Nil = nil,
                     @linecolor : String? = nil,
                     @linewidth : Int32 | Float64 | Nil = nil,
                     @linestyle : Int32? = nil,
                     @pointsize : Int32 | Float64 | Nil = nil,
                     @pointtype : Int32 | String | Nil = nil,
                     **options
                    )
        super(options)
      end

      def inst
        String.build do |io|
          io << "'-'"
          io << " title '#{@title}'" if @title
          io << " #{@style}" if @style
        end
      end

      def data
        Array(String).new.tap do |arr|
          @xdata.zip(@ydata, @zdata).each do |x, y, z|
            arr << "#{x} #{y} #{z}"
          end
          arr << "e"
        end
      end

      def dim
        @style =~ /circle/ ? 2 : 3
      end
    end

    class Plot2D(D) < Plot
      @@styles = [:image, :lines, :points]

      def initialize(@data : D,
                     @title : String? = nil, @style : Symbol | String | Nil = nil,
                     @format : String? = nil,
                     @dashtype : Array(Int32) | Int32 | String | Nil = nil,
                     @linecolor : String? = nil,
                     @linewidth : Int32 | Float64 | Nil = nil,
                     @linestyle : Int32? = nil,
                     @pointsize : Int32 | Float64 | Nil = nil,
                     @pointtype : Int32 | String | Nil = nil,
                     **options
                    )
        super(options)
      end

      def inst
        String.build do |io|
          io << "'-' matrix"
          io << " title '#{@title}'" if @title
          io << " #{@style}" if @style
        end
      end

      def data
        Array(String).new.tap do |arr|
          (0...@data.size).reverse_each do |i|
            arr << @data[i].join(" ")
          end
          arr << "e"
        end
      end

      def dim
        @style =~ /image/ ? 2 : 3
      end
    end

    # Creates a new instance of the gnuplot engine.
    #
    def initialize(@prologue : Enumerable(String) = [] of String, @epilogue : Enumerable(String) = ["exit"])
    end

    # Shows the chart.
    #
    def show(chart)
      commands = [] of String
      commands << "set xlabel '#{chart.xlabel}'" if chart.xlabel
      commands << "set ylabel '#{chart.ylabel}'" if chart.ylabel
      commands << "set zlabel '#{chart.zlabel}'" if chart.zlabel
      if xrange = chart.xrange
        commands << "set xrange[#{xrange.begin}:#{xrange.end}]"
      end
      if yrange = chart.yrange
        commands << "set yrange[#{yrange.begin}:#{yrange.end}]"
      end
      if zrange = chart.zrange
        commands << "set zrange[#{zrange.begin}:#{zrange.end}]"
      end
      if view = chart.view
        commands << "set view #{view[0]},#{view[1]}"
      end
      case name = chart.palette_name
      when :gray
        commands <<
          "set palette gray" <<
          "set style line 1 palette fraction 0.1" <<
          "set style line 2 palette fraction 0.2" <<
          "set style line 3 palette fraction 0.3" <<
          "set style line 4 palette fraction 0.4" <<
          "set style line 5 palette fraction 0.5" <<
          "set style line 6 palette fraction 0.6" <<
          "set style line 7 palette fraction 0.7" <<
          "set style line 8 palette fraction 0.8" <<
          "set style line 9 palette fraction 0.9" <<
          "unset colorbox"
      else
        if name
          commands += PALETTES[name].split("\n")
          commands << "unset colorbox"
        end
      end
      case show = chart.show_colorbox
      when true
        commands << "set colorbox"
      when false
        commands << "unset colorbox"
      end
      case show = chart.show_border
      when true
        commands << "set border 31"
      when false
        commands << "unset border"
      end
      case show = chart.show_xtics
      when true
        commands << "set xtics"
      when false
        commands << "unset xtics"
      end
      case show = chart.show_ytics
      when true
        commands << "set ytics"
      when false
        commands << "unset ytics"
      end
      unless chart.plots.empty?
        instruction = chart.dim? == 3 ? "splot " : "plot "
        instruction += chart.plots.map(&.inst).join(",")
        commands << instruction
        chart.plots.each { |plot| commands += plot.data }
      end
      run(commands)
    ensure
      chart.clear
    end

    # Runs a "gnuplot" process and feeds it `commands`.
    #
    # Returns an `IO` instance with the output.
    #
    def run(commands : Enumerable(String))
      Process.run("gnuplot") do |process|
        input = process.input
        output = process.output
        @prologue.each do |command|
          input.puts command
        end
        commands.each do |command|
          input.puts command
        end
        @epilogue.each do |command|
          input.puts command
        end
        IO::Memory.new.tap do |memory|
          IO.copy(output, memory)
          memory.rewind
        end
      end
    end

    {% begin %}
      # :nodoc:
      PALETTES = {
        {% palettes = `ls "#{__DIR__}"/../../etc/palettes/*.pal`.chomp.split("\n").sort %}
        {% for palette in (palettes) %}
          {% name = palette.split("/").last.split(".").first %}
          {{name.id}}: {{read_file(palette)}},
        {% end %}
      }
    {% end %}
  end
end
