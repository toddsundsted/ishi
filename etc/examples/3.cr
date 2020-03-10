{% if flag?(:png) %}
  require "../../src/ishi/png"
{% else %}
  require "../../src/ishi"
{% end %}

# Various types of points.
#
Ishi.new do
  canvas_size(480, 360)
  show_key(false)
  xrange(0..5)
  yrange(0..9)
  plot([1, 2, 3, 4], [5, 6, 7, 8], pointtype: 1, pointsize: 2)
  plot([1, 2, 3, 4], [4, 5, 6, 7], pointtype: "o", pointsize: 2)
  plot([1, 2, 3, 4], [3, 4, 5, 6], pointtype: "s", pointsize: 2)
  plot([1, 2, 3, 4], [2, 3, 4, 5], pointtype: "^", pointsize: 2)
  plot([1, 2, 3, 4], [1, 2, 3, 4], pointtype: "v", pointsize: 2, linecolor: "#88001100")
end
