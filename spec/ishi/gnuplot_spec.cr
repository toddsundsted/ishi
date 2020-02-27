require "../spec_helper"

Spectator.describe Ishi::Gnuplot do
  let(:chart) { Ishi::Gnuplot::Chart.new }
  subject { described_class.new(["set term dumb"]) }

  describe "#plot" do
    context "given a mathematical expression" do
      it "invokes 'plot'" do
        output = subject.show(chart.plot(Ishi::Gnuplot::PlotExp.new("sin(x)")))
        expect(output).to have(/^plot sin\(x\)/)
      end

      it "specifies the title" do
        output = subject.show(chart.plot(Ishi::Gnuplot::PlotExp.new("sin(x)", title: "foobar")))
        expect(output).to have(/title 'foobar'/)
      end

      it "specifies the style" do
        output = subject.show(chart.plot(Ishi::Gnuplot::PlotExp.new("sin(x)", style: :points)))
        expect(output).to have(/with points/)
      end
    end

    context "given one array of data" do
      it "invokes 'plot'" do
        output = subject.show(chart.plot(Ishi::Gnuplot::PlotY.new([1, 2, 3, 4])))
        expect(output).to have(/^plot '-'/)
      end

      it "specifies the title" do
        output = subject.show(chart.plot(Ishi::Gnuplot::PlotY.new([1, 2, 3, 4], title: "foobar")))
        expect(output).to have(/title 'foobar'/)
      end

      it "specifies the style" do
        output = subject.show(chart.plot(Ishi::Gnuplot::PlotY.new([1, 2, 3, 4], style: :points)))
        expect(output).to have(/with points/)
      end
    end

    context "given two arrays of data" do
      it "invokes 'plot'" do
        output = subject.show(chart.plot(Ishi::Gnuplot::PlotXY.new([1, 2, 3, 4], [0, 1, 2, 3])))
        expect(output).to have(/^plot '-'/)
      end

      it "specifies the title" do
        output = subject.show(chart.plot(Ishi::Gnuplot::PlotXY.new([1, 2, 3, 4], [0, 1, 2, 3], title: "foobar")))
        expect(output).to have(/title 'foobar'/)
      end

      it "specifies the style" do
        output = subject.show(chart.plot(Ishi::Gnuplot::PlotXY.new([1, 2, 3, 4], [0, 1, 2, 3], style: :points)))
        expect(output).to have(/with points/)
      end
    end

    context "given three arrays of data" do
      it "invokes 'splot'" do
        output = subject.show(chart.plot(Ishi::Gnuplot::PlotXYZ.new([1, 2, 3, 4], [0, 1, 2, 3], [0, 0, 1, 1])))
        expect(output).to have(/^splot '-'/)
      end

      it "specifies the title" do
        output = subject.show(chart.plot(Ishi::Gnuplot::PlotXYZ.new([1, 2, 3, 4], [0, 1, 2, 3], [0, 0, 1, 1], title: "foobar")))
        expect(output).to have(/title 'foobar'/)
      end

      it "specifies the style" do
        output = subject.show(chart.plot(Ishi::Gnuplot::PlotXYZ.new([1, 2, 3, 4], [0, 1, 2, 3], [0, 0, 1, 1], style: :lines)))
        expect(output).to have(/with lines/)
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
