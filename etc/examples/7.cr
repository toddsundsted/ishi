{% if flag?(:png) %}
  require "../../src/ishi/png"
{% else %}
  require "../../src/ishi"
{% end %}

# Bar chart with non-numeric x-axis labels
Ishi.new do
  canvas_size(480, 360)

  x = [1, 2, 3]
  y = [65, 30, 5]
  plot(x, y, title: "Visits", style: :boxes, fs: 0.25)
    .boxwidth(0.5)
    .ylabel("Visits (%)")
    .xlabel("Device")
    .xtics({1.0 => "mobile", 2.0 => "desktop", 3.0 => "tablet"})
end
