_      = require 'lodash'
async  = require 'async'
bcrypt = require 'bcrypt'
debug  = require('debug')('meshblu:authDevice')

module.exports = (uuid, token, callback=(->), dependencies={}) ->
  @Device = dependencies.Device ? require './models/device'
  device = new @Device uuid: uuid
  device.verifyToken token, (error, verified) =>
    return callback error if error?
    return callback new Error('Unable to find valid device') unless verified
    device.fetch (error, attributes) =>
      return callback error if error?
      callback null, attributes
