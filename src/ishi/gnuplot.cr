module Ishi
  # Gnuplot rendering engine.
  #
  # Requires "gnuplot" be installed and available.
  #
  class Gnuplot
    private abstract class Plot
      abstract def inst
      abstract def data
      abstract def dim

      @@styles = [] of Symbol

      private def check_style
        if @style
          unless @@styles.includes?(@style)
            raise ArgumentError.new("invalid style: #{@style.inspect}")
          end
        end
      end
    end

    private class PlotE < Plot
      @@styles = [:lines, :points]

      def initialize(@expression : String, @title : String?, @style : Symbol? = nil)
        check_style
      end

      def inst
        String.build do |io|
          io << "#{@expression}"
          io << " with #{@style}" if @style
          io << " title '#{@title}'" if @title
        end
      end

      def data
        [] of String
      end

      def dim
      end
    end

    private class Plot1(Y) < Plot
      @@styles = [:boxes, :lines, :points]

      def initialize(@ydata : Indexable(Y), @title : String?, @style : Symbol)
        check_style
      end

      def inst
        String.build do |io|
          io << "'-' with #{@style}"
          io << " title '#{@title}'" if @title
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

    private class Plot2(X, Y) < Plot
      @@styles = [:boxes, :lines, :points]

      def initialize(@xdata : Indexable(X), @ydata : Indexable(Y), @title : String?, @style : Symbol)
        check_style
      end

      def inst
        String.build do |io|
          io << "'-' with #{@style}"
          io << " title '#{@title}'" if @title
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

    private class Plot3(X, Y, Z) < Plot
      @@styles = [:circles, :lines, :points]

      def initialize(@xdata : Indexable(X), @ydata : Indexable(Y), @zdata : Indexable(Z), @title : String?, @style : Symbol)
        check_style
      end

      def inst
        String.build do |io|
          io << "'-' with #{@style}"
          io << " title '#{@title}'" if @title
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

    @plots = [] of Plot

    # Returns the number of plots.
    #
    def size
      @plots.size
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

    private def dim?
      dim
    rescue
      nil
    end

    # Clears the chart.
    #
    def clear
      @plots.clear
      @xlabel = @ylabel = @zlabel = nil
      @xrange = @yrange = @zrange = nil
    end

    # Plots a mathematical expression.
    #
    def plot(expression : String, title : String? = nil, style : Symbol? = nil)
      @plots << PlotE.new(expression, title, style)
      self
    end

    # Plots `y` using `x` ranging from `0` to `N-1`.
    #
    def plot(ydata : Indexable(Y), title : String? = nil, style : Symbol = :lines) forall Y
      {% raise "data must be numeric" unless Y < Number %}
      @plots << Plot1.new(ydata, title, style)
      self
    end

    # Plots `x` and `y`.
    #
    def plot(xdata : Indexable(X), ydata : Indexable(Y), title : String? = nil, style : Symbol = :lines) forall X, Y
      {% raise "data must be numeric" unless X < Number && Y < Number %}
      @plots << Plot2.new(xdata, ydata, title, style)
      self
    end

    # Plots `x`, `y` and `z`.
    #
    def plot(xdata : Indexable(X), ydata : Indexable(Y), zdata : Indexable(Z), title : String? = nil, style : Symbol = :points) forall X, Y, Z
      {% raise "data must be numeric" unless X < Number && Y < Number && Z < Number %}
      @plots << Plot3.new(xdata, ydata, zdata, title, style)
      self
    end

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

    # Shows the chart.
    #
    def show
      commands = [] of String
      commands << "set xlabel '#{@xlabel}'" if @xlabel
      commands << "set ylabel '#{@ylabel}'" if @ylabel
      commands << "set zlabel '#{@zlabel}'" if @zlabel
      if xrange = @xrange
        commands << "set xrange[#{xrange.begin}:#{xrange.end}]"
      end
      if yrange = @yrange
        commands << "set yrange[#{yrange.begin}:#{yrange.end}]"
      end
      if zrange = @zrange
        commands << "set zrange[#{zrange.begin}:#{zrange.end}]"
      end
      unless @plots.empty?
        instruction = dim? == 3 ? "splot " : "plot "
        instruction += @plots.map(&.inst).join(",")
        commands << instruction
        @plots.each { |plot| commands += plot.data }
      end
      run(commands)
    ensure
      clear
    end

    # Creates a new instance of the gnuplot engine.
    #
    def initialize(@prologue : Enumerable(String) = [] of String, @epilogue : Enumerable(String) = ["exit"])
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
