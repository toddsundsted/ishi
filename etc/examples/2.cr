{% if flag?(:png) %}
  require "../../src/ishi/png"
{% else %}
  require "../../src/ishi"
{% end %}

# Various types of lines.
#
Ishi.new do
  canvas_size(480, 360)
  show_key(false)
  xrange(0..5)
  yrange(0..9)
  plot("x + 4.0", dashtype: "-", linewidth: 2)
  plot("x + 3.0", dashtype: "_", linewidth: 2)
  plot("x + 2.0", dashtype: ".", linewidth: 2)
  plot("x + 1.0", dashtype: "..._", linewidth: 2)
  plot("x + 0.0", dashtype: [30, 10, 50, 10], linewidth: 2, linecolor: "#88001100")
end
