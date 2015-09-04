'use strict'

errors = require('./components/errors')
path = require('path')

module.exports = (app) ->

  #app.use('/api/things', require('./api/thing'))
  #app.use('/api/users', require('./api/user'))

  #app.use('/auth', require('./auth'))
  
  app.route('/:url(api|auth|components|app|bower_components|assets)/*')
  .get(errors[404])

  app.route('/*')
    .get (req, res) ->
      res.sendFile(path.resolve(app.get('appPath') + '/index.html'))
