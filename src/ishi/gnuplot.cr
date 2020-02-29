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
      @pointsize : Int32 | Float64 | Nil = nil
      @pointtype : Int32? = nil

      def initialize
        check_style
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
        "-." => 9,
        ":" => 3
      }

      private def parse_format
        if format = @format
          unless @linecolor
            if format =~ /^#([0-9A-F]{2}){3,4}$/i
              @linecolor = format
              return
            elsif %w(blue green red cyan magenta yellow black white).includes?(format)
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
        s = _style
        @style = s ? " with #{s}" : nil
        if @dashtype || @linecolor || @linewidth || @pointsize || @pointtype
          @style = String.build do |io|
            io << @style || ""
            io << " dt #{_dashtype}" if @dashtype
            io << " lc #{_linecolor}" if @linecolor
            io << " lw #{@linewidth}" if @linewidth
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
        @pointtype.to_s
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
                     @pointsize : Int32 | Float64 | Nil = nil,
                     @pointtype : Int32? = nil
                    )
        super()
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
                     @pointsize : Int32 | Float64 | Nil = nil,
                     @pointtype : Int32? = nil
                    )
        super()
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
                     @pointsize : Int32 | Float64 | Nil = nil,
                     @pointtype : Int32? = nil
                    )
        super()
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
                     @pointsize : Int32 | Float64 | Nil = nil,
                     @pointtype : Int32? = nil
                    )
        super()
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
        @style == :circles ? 2 : 3
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
  end
end
