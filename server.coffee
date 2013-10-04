express = require 'express'
assets = require 'connect-assets'
ccss = require 'ccss'
process.on 'uncaughtException', (err) ->
    console.error err
require('source-map-support').install()
app = express()
app.set 'view engine', 'coffee'
app.engine 'coffee', require('coffeecup').__express
app.use express.logger()
app.use express.favicon 'public/favicon.ico'
assets.cssCompilers.coffee =
    compileSync: (sourcePath, source, helperContext) ->
        template = require sourcePath
        ccss.compile template
app.use assets()
app.get '*', (req, res) ->
    res.render req.path.match(/[^\/]+/) || 'index', {}
app.use express.static __dirname + '/public'
app.listen 80