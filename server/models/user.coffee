'use strict'

mongoose = require('mongoose')
Schema = mongoose.Schema
crypto = require('crypto')
authTypes = ['github', 'twitter', 'facebook', 'google']

UserSchema = new Schema(
  name: String,
  email: { type: String, lowercase: true },
  role:
    type: String,
    default: 'user'
  hashedPassword: String,
  provider: String,
  salt: String,
  facebook: {},
  twitter: {},
  google: {},
  github: {}
)

#
# Virtuals
#
UserSchema
  .virtual('password')
  .set (password) ->
    this._password = password
    this.salt = this.makeSalt()
    this.hashedPassword = this.encryptPassword(password)
  .get () ->
    return this._password

# Public profile information
UserSchema
  .virtual('profile')
  .get () ->
    return {
      'name': this.name,
      'role': this.role
    }

# Non-sensitive info we'll be putting in the token
UserSchema
  .virtual('token')
  .get () ->
    return {
      '_id': this._id,
      'role': this.role
    }

#
# Validations
#

# Validate empty email
UserSchema
  .path('email')
  .validate((email) ->
    return true if (authTypes.indexOf(this.provider) != -1)
    return email.length
  , 'Email cannot be blank'
  )

# Validate empty password
UserSchema
  .path('hashedPassword')
  .validate((hashedPassword) ->
    return true if (authTypes.indexOf(this.provider) != -1)
    return hashedPassword.length
  , 'Password cannot be blank'
  )

# Validate email is not taken
UserSchema
  .path('email')
  .validate((value, respond) ->
    self = this
    this.constructor.findOne({email: value}, (err, user) ->
      throw err if (err) 
      if(user)
        return respond(true) if(self.id == user.id) 
        return respond(false)
      respond(true)
    )
  , 'The specified email address is already in use.')

validatePresenceOf = (value) ->
  return value && value.length


#
# Pre-save hook
#
UserSchema
  .pre 'save', (next) ->
    return next() if (!this.isNew) 

    if (!validatePresenceOf(this.hashedPassword) && authTypes.indexOf(this.provider) == -1)
      next(new Error('Invalid password'))
    else
      next()


#
# Methods
#
UserSchema.methods =
  #/**
  # * Authenticate - check if the passwords are the same
  # *
  # * @param {String} plainText
  # * @return {Boolean}
  # * @api public
  # */
  authenticate: (plainText) ->
    return this.encryptPassword(plainText) == this.hashedPassword

  #/**
  # * Make salt
  # *
  # * @return {String}
  # * @api public
  # */
  makeSalt: () ->
    return crypto.randomBytes(16).toString('base64')

  #/**
  # * Encrypt password
  # *
  # * @param {String} password
  # * @return {String}
  # * @api public
  # */
  encryptPassword: (password) ->
    return '' if (!password || !this.salt) 
    salt = new Buffer(this.salt, 'base64')
    return crypto.pbkdf2Sync(password, salt, 10000, 64).toString('base64')


module.exports = mongoose.model('User', UserSchema)
