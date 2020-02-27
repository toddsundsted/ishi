require "../spec_helper"

Spectator.describe Ishi::Gnuplot::Chart do
  subject { described_class.new }

  describe "#plot" do
    context "given a mathematical expression" do
      it "adds a mathematical expression plot to the chart" do
        subject.plot(Ishi::Gnuplot::PlotExp.new("sin(x)"))
        expect(subject.size).to eq(1)
      end
    end

    context "given one array of data" do
      it "adds a 2D plot to the chart" do
        subject.plot(Ishi::Gnuplot::PlotY.new([1, 2, 3, 4]))
        expect(subject.size).to eq(1)
        expect(subject.dim).to eq(2)
      end
    end

    context "given two arrays of data" do
      it "adds a 2D plot to the chart" do
        subject.plot(Ishi::Gnuplot::PlotXY.new([1, 2, 3, 4], [0, 1, 2, 3]))
        expect(subject.size).to eq(1)
        expect(subject.dim).to eq(2)
      end
    end

    context "given three arrays of data" do
      it "adds a 3D plot to the chart" do
        subject.plot(Ishi::Gnuplot::PlotXYZ.new([1, 2, 3, 4], [0, 1, 2, 3], [0, 0, 1, 1]))
        expect(subject.size).to eq(1)
        expect(subject.dim).to eq(3)
      end
    end

    context "given two plots" do
      it "adds two plots to the chart" do
        subject.plot(Ishi::Gnuplot::PlotY.new([1, 2, 3, 4])).plot(Ishi::Gnuplot::PlotExp.new("cos(x)"))
        expect(subject.size).to eq(2)
      end
    end
  end

  describe "#clear" do
    it "clears the chart" do
      subject.plot(Ishi::Gnuplot::PlotExp.new("2 * x + 1")).clear
      expect(subject.size).to eq(0)
    end
  end
end
