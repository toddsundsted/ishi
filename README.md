# 石の上にも三年

[![GitHub Release](https://img.shields.io/github/release/toddsundsted/ishi.svg)](https://github.com/toddsundsted/ishi/releases)
[![Build Status](https://travis-ci.org/toddsundsted/ishi.svg?branch=master)](https://travis-ci.org/toddsundsted/ishi)
[![Documentation](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://toddsundsted.github.io/ishi/)

Graph plotting package with a small API powered by gnuplot.

Requires [gnuplot](http://www.gnuplot.info/).

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  ishi:
    github: toddsundsted/ishi
```

2. Run `shards install`

## Usage

To display a line chart of the data points in `xdata` (the x values)
and `ydata` (the corresponding y values):

```crystal
require "ishi"

ishi = Ishi.new
ishi.plot(xdata, ydata)
ishi.show
```

Or, if you prefer command-style:

```crystal
require "ishi"

Ishi.new do
  plot(xdata, ydata)
end
```

`plot` accepts data points in several formats:
* `plot(ydata)` - y values in `ydata` with x values ranging from `0` to `ydata.size - 1`
* `plot(xdata, ydata)` - x values in `xdata` and corresponding y values in `ydata`
* `plot(xdata, ydata, zdata)` - x values from `xdata`, y values from `ydata`, and z values from `zdata`
* `plot(expression)` - any gnuplot-supported mathematical expression

`xdata`, `ydata` and `zdata` may be any data type that implements
`Indexable(Number)`. Chart dimensionality (2D or 3D) is inferred from
the data.

All `plot` methods/commands accept the optional named arguments
*title* and *style*. *title* specifies the title of the plot displayed
in the chart key. *style* specifies the style of the plot (line,
points, etc.). See the API documentation for details.

By default, Ishi pops open a window to display charts. However, Ishi
comes with extensions that display plots as text, HTML or images in
the terminal, or render plots to other `IO` destinations. Note: inline
image display only works with [ITerm2](https://www.iterm2.com/).

To plot the *sin(x)* function as text:

```crystal
require "ishi/text" # or "ishi/html" or "ishi/iterm2"

Ishi.new do
  plot("sin(x)")
end
```

This produces:

```
    1 +--------------------------------------------------------------------+
      |                *  *              +  *  **         +       *  *     |
  0.8 |-+             *   *                 *    *          sin(x* *******-|
      |              *     *                *    *               *    *    |
  0.6 |-+            *      *              *     *               *     * +-|
      |              *      *             *       *             *       *  |
  0.4 |*+            *      *             *       *             *       *+-|
      |*            *        *            *        *           *        *  |
  0.2 |*+           *        *            *        *           *        *+-|
      | *          *          *          *         *          *          * |
    0 |-*          *          *          *         *          *          *-|
      |  *         *          *         *           *         *           *|
 -0.2 |-+*         *          *         *           *         *          +*|
      |  *        *            *       *             *       *            *|
 -0.4 |-+*        *            *       *             *       *           +*|
      |   *      *              *      *             *      *              |
 -0.6 |-+ *     *               *     *              *      *            +-|
      |    *    *               *     *               *     *              |
 -0.8 |-+   *   *                *   *                 *   *             +-|
      |     *  *       +         **  *   +             *  *                |
   -1 +--------------------------------------------------------------------+
     -10              -5                 0                5                10
```

## Contributors

- [Todd Sundsted](https://github.com/toddsundsted) - creator and maintainer
