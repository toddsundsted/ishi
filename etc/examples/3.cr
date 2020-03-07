require "../../src/ishi"

# Various types of points.
#
Ishi.new do
  canvas_size(480, 360)
  plot([5, 6, 7, 8], pointtype: 1, pointsize: 2)
  plot([4, 5, 6, 7], pointtype: "o", pointsize: 2)
  plot([3, 4, 5, 6], pointtype: "s", pointsize: 2)
  plot([2, 3, 4, 5], pointtype: "^", pointsize: 2)
  plot([1, 2, 3, 4], pointtype: "v", pointsize: 2)
end
