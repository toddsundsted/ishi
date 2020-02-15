require "../spec_helper"

Spectator.describe Ishi::Gnuplot do
  subject { described_class.new(["set term dumb"]) }

  describe "#plot" do
    context "given a mathematical expression" do
      it "adds a mathematical expression plot to the chart" do
        subject.plot("sin(x)")
        expect(subject.size).to eq(1)
      end

      it "invokes 'plot'" do
        output = subject.plot("sin(x)").show
        expect(output).to have(/^plot sin\(x\)/)
      end

      it "specifies the title" do
        output = subject.plot("sin(x)", title: "foobar").show
        expect(output).to have(/title 'foobar'/)
      end

      it "specifies the style" do
        output = subject.plot("sin(x)", style: :points).show
        expect(output).to have(/with points/)
      end
    end

    context "given one array of data" do
      it "adds a 2D plot to the chart" do
        subject.plot([1, 2, 3, 4])
        expect(subject.size).to eq(1)
        expect(subject.dim).to eq(2)
      end

      it "invokes 'plot'" do
        output = subject.plot([1, 2, 3, 4]).show
        expect(output).to have(/^plot '-'/)
      end

      it "specifies the title" do
        output = subject.plot([1, 2, 3, 4], title: "foobar").show
        expect(output).to have(/title 'foobar'/)
      end

      it "specifies the style" do
        output = subject.plot([1, 2, 3, 4], style: :points).show
        expect(output).to have(/with points/)
      end
    end

    context "given two arrays of data" do
      it "adds a 2D plot to the chart" do
        subject.plot([1, 2, 3, 4], [0, 1, 2, 3])
        expect(subject.size).to eq(1)
        expect(subject.dim).to eq(2)
      end

      it "invokes 'plot'" do
        output = subject.plot([1, 2, 3, 4], [0, 1, 2, 3]).show
        expect(output).to have(/^plot '-'/)
      end

      it "specifies the title" do
        output = subject.plot([1, 2, 3, 4], [0, 1, 2, 3], title: "foobar").show
        expect(output).to have(/title 'foobar'/)
      end

      it "specifies the style" do
        output = subject.plot([1, 2, 3, 4], [0, 1, 2, 3], style: :points).show
        expect(output).to have(/with points/)
      end
    end

    context "given three arrays of data" do
      it "adds a 3D plot to the chart" do
        subject.plot([1, 2, 3, 4], [0, 1, 2, 3], [0, 0, 1, 1])
        expect(subject.size).to eq(1)
        expect(subject.dim).to eq(3)
      end

      it "invokes 'splot'" do
        output = subject.plot([1, 2, 3, 4], [0, 1, 2, 3], [0, 0, 1, 1]).show
        expect(output).to have(/^splot '-'/)
      end

      it "specifies the title" do
        output = subject.plot([1, 2, 3, 4], [0, 1, 2, 3], [0, 0, 1, 1], title: "foobar").show
        expect(output).to have(/title 'foobar'/)
      end

      it "specifies the style" do
        output = subject.plot([1, 2, 3, 4], [0, 1, 2, 3], [0, 0, 1, 1], style: :lines).show
        expect(output).to have(/with lines/)
      end
    end

    context "given two plots" do
      it "adds two plots to the chart" do
        subject.plot([1, 2, 3, 4]).plot("cos(x)")
        expect(subject.size).to eq(2)
      end
    end
  end

  describe "#xlabel" do
    it "adds a label to the x axis" do
      output = subject.xlabel("foobar").show
      expect(output).to have("set xlabel 'foobar'")
    end
  end

  describe "#ylabel" do
    it "adds a label to the y axis" do
      output = subject.ylabel("foobar").show
      expect(output).to have("set ylabel 'foobar'")
    end
  end

  describe "#zlabel" do
    it "adds a label to the z axis" do
      output = subject.zlabel("foobar").show
      expect(output).to have("set zlabel 'foobar'")
    end
  end

  describe "#xrange" do
    it "sets the range of the x axis" do
      output = subject.xrange(-1..1).show
      expect(output).to have("set xrange[-1:1]")
    end
  end

  describe "#yrange" do
    it "sets the range of the y axis" do
      output = subject.yrange(-1..1).show
      expect(output).to have("set yrange[-1:1]")
    end
  end

  describe "#zrange" do
    it "sets the range of the z axis" do
      output = subject.zrange(-1..1).show
      expect(output).to have("set zrange[-1:1]")
    end
  end

  describe "#clear" do
    it "clears the chart" do
      subject.plot("2 * x + 1").clear
      expect(subject.size).to eq(0)
    end
  end

  describe "#show" do
    it "displays the chart" do
      output = subject.plot("2 * x + 1").show
      expect(output).to have("plot 2 * x + 1")
    end

    it "clears the chart" do
      subject.plot("2 * x + 1").show
      expect(subject.size).to eq(0)
    end
  end
end
