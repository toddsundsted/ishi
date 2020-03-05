require "../spec_helper"

alias Options = NamedTuple(
  title: String | Nil,
  style: Symbol | String | Nil,
  format: String | Nil,
  dashtype: Array(Int32) | Int32 | String | Nil,
  linecolor: String | Nil,
  linewidth: Int32 | Float64 | Nil,
  pointsize: Int32 | Float64 | Nil,
  pointtype: Int32 | String | Nil,
  dt: Array(Int32) | Int32 | String | Nil,
  lc: String | Nil,
  lw: Int32 | Float64 | Nil,
  ps: Int32 | Float64 | Nil,
  pt: Int32 | Nil
)

def options(options)
  Options.from({
    "title" => options["title"]?,
    "style" => options["style"]?,
    "format" => options["format"]?,
    "dashtype" => options["dashtype"]?,
    "linecolor" => options["linecolor"]?,
    "linewidth" => options["linewidth"]?,
    "pointsize" => options["pointsize"]?,
    "pointtype" => options["pointtype"]?,
    "dt" => options["dt"]?,
    "lc" => options["lc"]?,
    "lw" => options["lw"]?,
    "ps" => options["ps"]?,
    "pt" => options["pt"]?
  })
end

Spectator.describe Ishi::Gnuplot do
  subject { described_class.new(["set term dumb"]) }
  let(:chart) { Ishi::Gnuplot::Chart.new }

  describe "#plot" do
    EXAMPLES = [
      { {title: "foobar"}, /title 'foobar'/ },
      { {style: :lines}, /with lines/ },
      { {dashtype: [2, 2]}, /dt \(2,2\)/ },
      { {dashtype: "--  "}, /dt "--  "/ },
      { {linecolor: "red"}, /lc rgb "red"/ },
      { {linewidth: 2.3}, /lw 2.3/ },
      { {pointsize: 1.3}, /ps 1.3/ },
      { {pointtype: 1}, /pt 1/ },
      { {pointtype: "+"}, /pt 1/ },
      { {style: :points, dashtype: ".. "}, /with linespoints/ },
      { {style: :points, linewidth: 1.3}, /with linespoints/ },
      { {style: :lines, pointsize: 1.3}, /with linespoints/ },
      { {style: :lines, pointtype: 1}, /with linespoints/ },
      { {pointsize: 1.3}, /with linespoints/ },
      { {pointtype: 1}, /with linespoints/ },
      { {format: "red"}, /lc rgb "red"/ },
      { {format: "#ff0000"}, /lc rgb "#ff0000"/ },
      { {format: "r"}, /lc rgb "red"/ },
      { {format: "+"}, /pt 1/ },
      { {format: ":"}, /dt 3/ },
      { {dt: 1}, /dt 1/ },
      { {lc: "#80ff00ee"}, /lc rgb "#80ff00ee"/ },
      { {lw: 3}, /lw 3/ },
      { {ps: 2}, /ps 2/ },
      { {pt: 2}, /pt 2/ }
    ]

    context "given a mathematical expression" do
      it "invokes 'plot'" do
        commands = subject.show(chart.plot(Ishi::Gnuplot::PlotExp.new("sin(x)")))
        expect(commands).to have(/^plot sin\(x\)/)
      end

      sample EXAMPLES do |example|
        it "generates commands" do
          commands = subject.show(chart.plot(Ishi::Gnuplot::PlotExp.new("sin(x)", **options(example[0]))))
          expect(commands).to have(example[1])
        end
      end
    end

    context "given one array of data" do
      it "invokes 'plot'" do
        output = subject.show(chart.plot(Ishi::Gnuplot::PlotY.new([1, 2, 3, 4])))
        expect(output).to have(/^plot '-'/)
      end

      sample EXAMPLES do |example|
        it "generates commands" do
          commands = subject.show(chart.plot(Ishi::Gnuplot::PlotY.new([1, 2], **options(example[0]))))
          expect(commands).to have(example[1])
        end
      end
    end

    context "given two arrays of data" do
      it "invokes 'plot'" do
        output = subject.show(chart.plot(Ishi::Gnuplot::PlotXY.new([1, 2, 3, 4], [0, 1, 2, 3])))
        expect(output).to have(/^plot '-'/)
      end

      sample EXAMPLES do |example|
        it "generates commands" do
          commands = subject.show(chart.plot(Ishi::Gnuplot::PlotXY.new([1, 2], [0, 1], **options(example[0]))))
          expect(commands).to have(example[1])
        end
      end
    end

    context "given three arrays of data" do
      it "invokes 'splot'" do
        output = subject.show(chart.plot(Ishi::Gnuplot::PlotXYZ.new([1, 2, 3, 4], [0, 1, 2, 3], [0, 0, 1, 1])))
        expect(output).to have(/^splot '-'/)
      end

      sample EXAMPLES do |example|
        it "generates commands" do
          commands = subject.show(chart.plot(Ishi::Gnuplot::PlotXYZ.new([1, 2], [0, 1], [0, 0], **options(example[0]))))
          expect(commands).to have(example[1])
        end
      end
    end

    context "given an array of values" do
      it "invokes 'splot...matrix'" do
        output = subject.show(chart.plot(Ishi::Gnuplot::Plot2D.new([[1, 2], [3, 4]])))
        expect(output).to have(/^splot '-' matrix/)
      end

      sample EXAMPLES do |example|
        it "generates commands" do
          commands = subject.show(chart.plot(Ishi::Gnuplot::Plot2D.new([[1, 2], [3, 4]], **options(example[0]))))
          expect(commands).to have(example[1])
        end
      end
    end
  end

  describe "#xlabel" do
    it "adds a label to the x axis" do
      output = subject.show(chart.xlabel("foobar"))
      expect(output).to have("set xlabel 'foobar'")
    end
  end

  describe "#ylabel" do
    it "adds a label to the y axis" do
      output = subject.show(chart.ylabel("foobar"))
      expect(output).to have("set ylabel 'foobar'")
    end
  end

  describe "#zlabel" do
    it "adds a label to the z axis" do
      output = subject.show(chart.zlabel("foobar"))
      expect(output).to have("set zlabel 'foobar'")
    end
  end

  describe "#xrange" do
    it "sets the range of the x axis" do
      output = subject.show(chart.xrange(-1..1))
      expect(output).to have("set xrange[-1:1]")
    end
  end

  describe "#yrange" do
    it "sets the range of the y axis" do
      output = subject.show(chart.yrange(-1..1))
      expect(output).to have("set yrange[-1:1]")
    end
  end

  describe "#zrange" do
    it "sets the range of the z axis" do
      output = subject.show(chart.zrange(-1..1))
      expect(output).to have("set zrange[-1:1]")
    end
  end

  describe "#view" do
    it "sets the viewing angle for 3D charts" do
      output = subject.show(chart.view(60, 30))
      expect(output).to have("set view 60,30")
    end
  end

  describe "#palette" do
    it "sets the palette" do
      output = subject.show(chart.palette(:gray))
      expect(output).to have("set palette gray")
    end
  end

  describe "#show_colorbox" do
    it "shows the colorbox" do
      output = subject.show(chart.show_colorbox(true))
      expect(output).to have("set colorbox")
    end

    it "hides the colorbox" do
      output = subject.show(chart.show_colorbox(false))
      expect(output).to have("unset colorbox")
    end
  end

  describe "#show_border" do
    it "shows the border" do
      output = subject.show(chart.show_border(true))
      expect(output).to have("set border 31")
    end

    it "hides the border" do
      output = subject.show(chart.show_border(false))
      expect(output).to have("unset border")
    end
  end

  describe "#show_xtics" do
    it "shows the xtics" do
      output = subject.show(chart.show_xtics(true))
      expect(output).to have("set xtics")
    end

    it "hides the xtics" do
      output = subject.show(chart.show_xtics(false))
      expect(output).to have("unset xtics")
    end
  end

  describe "#show_ytics" do
    it "shows the ytics" do
      output = subject.show(chart.show_ytics(true))
      expect(output).to have("set ytics")
    end

    it "hides the ytics" do
      output = subject.show(chart.show_ytics(false))
      expect(output).to have("unset ytics")
    end
  end

  describe "#show" do
    it "displays the chart" do
      output = subject.show(chart.plot(Ishi::Gnuplot::PlotExp.new("2 * x + 1")))
      expect(output).to have("plot 2 * x + 1")
    end

    it "clears the chart" do
      subject.show(chart.plot(Ishi::Gnuplot::PlotExp.new("2 * x + 1")))
      expect(chart.size).to eq(0)
    end
  end
end
