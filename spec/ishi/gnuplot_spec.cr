require "../spec_helper"

Spectator.describe Ishi::Gnuplot do
  subject { described_class.new(Ishi::SpecHelper.new, ["set term dumb"]) }
  let(:chart) { Ishi::Gnuplot::Chart.new }

  describe "#plot" do
    EXAMPLES = [
      { {title: "foobar"}, /title 'foobar'/ },                   # sets title
      { {style: :lines}, /with lines/ },                         # sets style
      { {dashtype: [2, 2]}, /dt \(2,2\)/ },                      # sets dashtype
      { {dashtype: "--  "}, /dt "--  "/ },                       # sets dashtype
      { {linecolor: "red"}, /lc rgb "red"/ },                    # sets linecolor
      { {linewidth: 2.3}, /lw 2.3/ },                            # sets linewidth
      { {linestyle: 1}, /ls 1/ },                                # sets linestyle
      { {pointsize: 1.3}, /ps 1.3/ },                            # sets pointsize
      { {pointtype: 1}, /pt 1/ },                                # sets pointtype
      { {pointtype: "+"}, /pt 1/ },                              # sets pointtype
      { {style: :points, dashtype: ".. "}, /with linespoints/ }, # infers linespoints
      { {style: :points, linewidth: 1.3}, /with linespoints/ },  # infers linespoints
      { {style: :lines, pointsize: 1.3}, /with linespoints/ },   # infers linespoints
      { {style: :lines, pointtype: 1}, /with linespoints/ },     # infers linespoints
      { {pointsize: 1.3}, /with linespoints/ },                  # infers linespoints
      { {pointtype: 1}, /with linespoints/ },                    # infers linespoints
      { {format: "red"}, /lc rgb "red"/ },                       # sets linecolor
      { {format: "#ff0000"}, /lc rgb "#ff0000"/ },               # sets linecolor
      { {format: "r"}, /lc rgb "red"/ },                         # sets linecolor
      { {format: "+"}, /pt 1/ },                                 # sets pointtype
      { {format: ":"}, /dt 3/ },                                 # sets dashtype
      { {dt: 1}, /dt 1/ },                                       # sets dashtype
      { {lc: "#80ff00ee"}, /lc rgb "#80ff00ee"/ },               # sets linecolor
      { {lw: 3}, /lw 3/ },                                       # sets linewidth
      { {ls: 1}, /ls 1/ },                                       # sets linestyle
      { {ps: 2}, /ps 2/ },                                       # sets pointsize
      { {pt: 2}, /pt 2/ },                                       # sets pointtype
      { {fs: 2}, /fs pattern 2/ },                               # sets fillstyle
      { {fs: 0.1}, /fs solid 0.1/ }                              # sets fillstyle
    ]

    context "given a mathematical expression" do
      it "invokes 'plot'" do
        commands = subject.show(chart.plot(Ishi::Gnuplot::PlotExp.new("sin(x)")))
        expect(commands).to have(/^plot sin\(x\)/)
      end

      {% for example in EXAMPLES %}
        it "generates commands" do
          commands = subject.show(chart.plot(Ishi::Gnuplot::PlotExp.new("sin(x)", **{{example[0]}})))
          expect(commands).to have({{example[1]}})
        end
      {% end %}
    end

    context "given one array of data" do
      it "invokes 'plot'" do
        output = subject.show(chart.plot(Ishi::Gnuplot::PlotY.new([1, 2, 3, 4])))
        expect(output).to have(/^plot '-'/)
      end

      {% for example in EXAMPLES %}
        it "generates commands" do
          commands = subject.show(chart.plot(Ishi::Gnuplot::PlotY.new([1, 2], **{{example[0]}})))
          expect(commands).to have({{example[1]}})
        end
      {% end %}
    end

    context "given two arrays of data" do
      it "invokes 'plot'" do
        output = subject.show(chart.plot(Ishi::Gnuplot::PlotXY.new([1, 2, 3, 4], [0, 1, 2, 3])))
        expect(output).to have(/^plot '-'/)
      end

      {% for example in EXAMPLES %}
        it "generates commands" do
          commands = subject.show(chart.plot(Ishi::Gnuplot::PlotXY.new([1, 2], [0, 1], **{{example[0]}})))
          expect(commands).to have({{example[1]}})
        end
      {% end %}
    end

    context "given three arrays of data" do
      it "invokes 'splot'" do
        output = subject.show(chart.plot(Ishi::Gnuplot::PlotXYZ.new([1, 2, 3, 4], [0, 1, 2, 3], [0, 0, 1, 1])))
        expect(output).to have(/^splot '-'/)
      end

      {% for example in EXAMPLES %}
        it "generates commands" do
          commands = subject.show(chart.plot(Ishi::Gnuplot::PlotXYZ.new([1, 2], [0, 1], [0, 0], **{{example[0]}})))
          expect(commands).to have({{example[1]}})
        end
      {% end %}
    end

    context "given an array of values" do
      it "invokes 'splot...matrix'" do
        output = subject.show(chart.plot(Ishi::Gnuplot::Plot2D.new([[1, 2], [3, 4]])))
        expect(output).to have(/^splot '-' matrix/)
      end

      {% for example in EXAMPLES %}
        it "generates commands" do
          commands = subject.show(chart.plot(Ishi::Gnuplot::Plot2D.new([[1, 2], [3, 4]], **{{example[0]}})))
          expect(commands).to have({{example[1]}})
        end
      {% end %}
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

  describe "#boxwidth" do
    it "sets the default width of boxes" do
      output = subject.show(chart.boxwidth(1.55))
      expect(output).to have("set boxwidth 1.55")
    end
  end

  describe "#xtics" do
    it "sets non-numeric tic labels on the x-axis" do
      output = subject.show(chart.xtics({1.0 => "A", 3.0 => "C"}))
      expect(output).to have("set xtics (\"A\" 1.0, \"C\" 3.0)")
    end
  end

  describe "#view" do
    it "sets the viewing angle for 3D charts" do
      output = subject.show(chart.view(60, 30))
      expect(output).to have("set view 60,30")
    end
  end

  describe "#margin" do
    it "sets the margin" do
      output = subject.show(chart.margin(left: 6, right: 6, top: true, bottom: false))
      expect(output).to have("set lmargin 6", "set rmargin 6", "set tmargin -1")
    end
  end

  describe "#palette" do
    it "sets the palette" do
      output = subject.show(chart.palette(:gray))
      expect(output).to have("set palette gray")
    end

    it "hides the colorbox" do
      output = subject.show(chart.palette(:gray, colorbox: false))
      expect(output).to have("unset colorbox")
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

  describe "#show_key" do
    it "shows the key" do
      output = subject.show(chart.show_key(true))
      expect(output).to have("set key")
    end

    it "hides the key" do
      output = subject.show(chart.show_key(false))
      expect(output).to have("unset key")
    end
  end

  describe "#show" do
    it "displays the chart" do
      output = subject.show(chart.plot(Ishi::Gnuplot::PlotExp.new("2 * x + 1")))
      expect(output).to have("plot 2 * x + 1")
    end

    it "displays the charts" do
      chart1 = Ishi::Gnuplot::Chart.new.plot(Ishi::Gnuplot::PlotExp.new("sin(x)"))
      chart2 = Ishi::Gnuplot::Chart.new.plot(Ishi::Gnuplot::PlotExp.new("cos(x)"))
      output = subject.show([chart1, chart2], 2, 1)
      expect(output).to have("plot sin(x)", "plot cos(x)")
    end

    it "clears the chart" do
      subject.show(chart.plot(Ishi::Gnuplot::PlotExp.new("x")))
      expect(chart.size).to eq(0)
    end
  end
end
