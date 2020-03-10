{% if flag?(:png) %}
  require "../../src/ishi/png"
{% else %}
  require "../../src/ishi"
{% end %}

# Plot data points and the equation of a line.
#
Ishi.new do
  canvas_size(480, 360)
  plot([1, 2, 3, 4, 5], [1.0, 1.4, 1.9, 2.4, 2.6], "ko", title: "data")
  plot("0.4 * x + 0.7", "b--")
end
