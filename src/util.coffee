# modules
fs = require 'fs'
path = require 'path'
execFile = require('child_process').execFile
mime = require 'mime'
_ = require 'underscore'
Q = require 'q'
svgo = new (require('svgo'))()
pretty = require 'cssbeautify'
phantomjs = path.resolve(__dirname, '../node_modules/phantomjs/bin/phantomjs')
svgToPngFile = path.resolve(__dirname, './', 'svgToPng.js')

module.exports =

  # returns binary data as encoded string
  encodeImage: (data, type, format) ->
    str = ','

    formatMap =
      'svg': '\'data:image/svg+xml',
      'png': '\'data:image/png'

    if type is 'base64'
      str = ';base64,'
      encoded = new Buffer(data).toString 'base64'
    else
      encoded = encodeURIComponent(new Buffer(data).toString())

    formatMap[format] + str + encoded + '\''

  # returns a rounded string from a float or string
  roundNum: (num) ->
    Math.round(num).toString()

  # checks if there are spaces in the filename
  hasSpace: (filename) ->
    filename.indexOf(' ') >= 0

  # replaces spaces in filenames with dashes
  replaceSpaceInFilename: (oldFilename, newFilename, inDir) ->
    fs.renameSync(inDir + '/' + oldFilename, inDir + '/' + newFilename)

  # trims file extension from filename
  trimExt: (filename) ->
    # return filename.split('.')[0]
    filename.replace(/\.[^/.]+$/, '')

  # removes files from a list that aren't SVG images
  filterNonSvgFiles: (files, dir) ->
    _.filter files, (file) ->
      fs.statSync( path.join(dir + '/' + file) ).isFile() == true &&
      mime.lookup(file) == 'image/svg+xml'

  # returns an optimized SVG data string as a promise
  optimizeSvg: (data) ->
    d = Q.defer()
    svgo.optimize data, (result) ->
      d.reject new Error(result.error) if result.error
      d.resolve result
    d.promise

  # spins up phantomjs and saves SVGs as PNGs
  # phantomjs will output WARNINGS to stderr so ignore for now
  saveSvgAsPng: (sourceFileName, destinationFileName, height, width) ->
    args = [phantomjs, svgToPngFile, sourceFileName, destinationFileName, height, width]
    d = Q.defer()
    execFile process.execPath, args, (err, stdout, stderr) ->
      if err
        d.reject new Error err
      else if stdout.length > 0
        d.reject new Error stdout.toString().trim()
      else
        d.resolve destinationFileName
    d.promise

  # returns a string that can be saved as a CSS file
  createCssRules: (results, opts) ->
    # string to prefix classnames with
    cssClassnamePrefix = if opts.classname? then opts.classname else ''

    str = ''
    _.each results, (res, i) ->
      height = if not isNaN res.height then "height:#{res.height}px;" else ''
      width = if not isNaN res.width then "width:#{res.width}px;" else ''
      str +=
        ".#{cssClassnamePrefix + res.name}{" +
        "#{height}" +
        "#{width}" +
        "background-image:url(#{res.svgdatauri});" +
        "}" +
        ".no-inlinesvg .#{cssClassnamePrefix + res.name}{" +
        "background-image:url(#{res.pngdatauri});" +
        "}"

      # fallback PNG images
      if !opts.nopng
        str +=
          ".no-datauri .#{cssClassnamePrefix + res.name}{" +
          "background-image:url('#{res.pngpath}');" +
          "}"
    str

  # returns a "beautified" version of a css string
  prettyCss: (str) ->
    pretty str