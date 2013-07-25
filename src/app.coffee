# modules
fs = require 'fs'
path = require 'path'
_ = require 'underscore'
Q = require 'q'
colors = require 'colors'
microtime = require 'microtime'
util = require path.resolve(__dirname, './', 'util')
msg = require path.resolve(__dirname, './', 'msg')

# Q wrappers for some node methods
readDir = Q.denodeify fs.readdir
readFile = Q.denodeify fs.readFile
writeFile = Q.denodeify fs.writeFile
pathExists = Q.denodeify fs.exists

module.exports = (args, opts) ->

  # temp (these will be passed as arguments)
  inDir = path.resolve(__dirname, '..', 'test', 'inDir')
  outDir = path.resolve(__dirname, '..', 'test', 'outDir')
  resultsTemp = require(path.resolve(__dirname, '../test', 'results.json'))

  # name of the CSS file output
  cssFilename = 'iconr.css'

  # string to place at the top of the CSS file
  iconrHeader = '/* generated by iconr */\n\n'

  # stores results through the promise chain
  results = []

  # logs data about the application operations
  if opts.verbose
    log =
      appStart: microtime.now()
      appEnd: 0
      svgCount: 0
      svgSize: 0

  # confirm input directory exists
  pathExists inDir, (exists) ->

    if exists

      # read files in directory
      readDir(inDir)
        .then( (files) -> # filter anything that isn't an SVG
          util.filterNonSvgFiles files
        )
        .then( (filteredFiles) -> # read SVG data into an array

          # log icon count
          if opts.verbose
            log.svgCount = filteredFiles.length

          queue = []

          filteredFiles.forEach (file) ->
            svgPath = path.resolve inDir, file
            queue.push readFile(svgPath, 'utf8')

            # log total file size of the SVG files we're optimizing
            if opts.verbose
              log.svgSize += fs.statSync(svgPath).size

            # add to results
            results.push
              name: util.trimExt file
              svgpath: svgPath

          Q.all(queue)

        )
        # .then( (svgData) -> # optimize SVG data and get width & heights

        #   queue = []

        #   svgData.forEach (svg) ->
        #     queue.push util.optimizeSvg(svg)

        #   Q.all(queue)

        # )
        # .then( (data) -> # merge compressed SVG data into results

        #   _.each data, (obj, i) ->

        #     svgData =
        #       svgsrc: obj.data
        #       svgdatauri: util.encodeImage(obj.data, 'base64', 'svg')
        #       height: util.roundNum(obj.info.height)
        #       width: util.roundNum(obj.info.width)

        #     _.extend results[i], svgData

        # )
        # .then( -> # convert SVGs to PNGs

        #   # console.log 'converting SVGs to PNG'

        #   queue = []

        #   _.each results, (obj) ->
        #     destFile = path.resolve(outDir, obj.name + '.png')
        #     queue.push util.saveSvgAsPng(obj.svgpath, destFile)

        #   Q.all(queue)

        # )
        # .then( (pngPaths) -> # read PNGs into memory

        #   # console.log 'conversion complete'

        #   queue = []

        #   pngPaths.forEach (path, i) ->
        #     queue.push readFile(path, 'utf8')
        #     _.extend results[i], pngpath: path # add to results

        #   Q.all(queue)

        # )
        # .then( (pngData) -> # convert PNGs to data strings

        #   pngData.forEach (data, i) ->
        #     _.extend results[i], pngdatauri: util.encodeImage(data, 'base64', 'png') # add to results

        # )
        .then( -> # generate a string of CSS rules from the results

          iconrHeader + util.createCssRules resultsTemp

        )
        .then( (cssString) -> # save generated CSS to file

          # if pretty print is required
          if opts.pretty
            cssString = util.prettyCss cssString

          writeFile path.resolve(outDir, '..', cssFilename), cssString

        )
        .fail( (error) -> # errors should output here

          msg.data 'error', error

        )
        .finally( ->

          # in debug mode also expose results object
          if opts.debug
            msg.dump resultsTemp

          # log a summary message if in verbose mode
          if opts.verbose
            log.appEnd = microtime.now()
            msg.summary log

        )
        .done() # finished!

    else
      msg.log 'error', 'wrongDirectory'
