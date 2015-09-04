'use strict'

express = require('express')
morgan = require('morgan')
bodyParser = require('body-parser')
errorHandler = require('errorhandler')
path = require('path')
config = require('./environment')
mongoose = require('mongoose')

module.exports = (app) ->
  env = app.get('env')
  app.use(bodyParser.urlencoded({ extended: false }))
  app.use(bodyParser.json())
  
  if (env == 'production')
    app.use(favicon(path.join(config.root, 'public', 'favicon.ico')))
    app.use(express.static(path.join(config.root, 'public')))
    app.set('appPath', path.join(config.root, 'public'))
    app.use(morgan('dev'))

  if (env == 'development' || env == 'test') 
    app.use(require('connect-livereload')())
    app.use(express.static(path.join(config.root, '.tmp')))
    app.use(express.static(path.join(config.root, 'client')))
    app.set('appPath', path.join(config.root, 'client'))
    app.use(morgan('dev'))
    app.use(errorHandler()) # Error handler - has to be last
