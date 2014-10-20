[![NPM version](http://img.shields.io/npm/v/iconr.svg?style=flat)](https://www.npmjs.org/package/iconr)
[![Dependency Status](http://img.shields.io/david/okize/iconr.svg?style=flat)](https://david-dm.org/okize/iconr)
[![Downloads](http://img.shields.io/npm/dm/iconr.svg?style=flat)](https://www.npmjs.org/package/iconr)

# Iconr

## Description
CLI tool that parses a directory of SVG images and outputs a CSS file of inlined data URIs as well as a directory of PNG images for fallback.

![Iconr Screenshot](https://raw.github.com/okize/iconr/gh-pages/iconr-screenshot.gif)

## Usage

```
Usage:

  iconr [inputDirectory] [outputDirectory] -options

Description:

  Parses a directory of SVG images and outputs a CSS file of inlined data URIs as well as a directory of PNG images for fallback.

Options:

  -h, --help           Output usage information
  -V, --version        Output version number
  -a, --analytics      Displays a summary of application process tasks
  -v, --verbose        Verbose mode: log application progress to the console
  -d, --debug          Debug mode: will output additional information for development
  -p, --pretty         Output CSS in a "beautified" format
  -b, --b64            Base64 encode SVG data URI (fallback PNG is always Base64)
  -N, --nopngdata      Suppress creation of PNG fallback data URI (needed for IE8)
  -n, --nopng          Suppress creation of PNG fallback images (needed for < IE8)
  -s, --separatecss    Create separate stylesheets for IE
  -o, --optimizesvg    Will attempt to optimize the SVG to minimize file size
  -c, --classname      Set a prefix for css classes (default classname is SVG filename)
  -f, --filename       Set filename of css output (default is iconr.css)
  -k, --killcomment    Removes the "generated by iconr" CSS comment
  -S, --stdout         Output CSS to stdout instead of saving to a file

Examples:

  $ iconr ./svgIcons ./svgCss -vao
  $ iconr ./images/svg-icons ./css -pn --filename="svg-icons.css"

```

## Installing

```
  $ npm install -g iconr
```

## Dependencies

Expects [Modernizr](http://modernizr.com/) classes on front-end.

## Contributing to Iconr

Contributions and pull requests are very welcome. Please follow these guidelines when submitting new code.

1. Make all changes in Coffeescript files, **not** JavaScript files.
2. Use `npm install -d` to install the correct development dependencies.
3. Use `gulp watch` to generate Iconr's compiled JavaScript files as you code.
4. Submit a Pull Request using GitHub.

## License

Released under the [MIT License](http://www.opensource.org/licenses/mit-license.php).
