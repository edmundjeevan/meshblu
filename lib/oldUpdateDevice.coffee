Device = require './models/device'

module.exports = (uuid, params={}, callback=_.noop, dependencies={})->
  getDevice  = dependencies.getDevice ? require './getDevice'
  clearCache = dependencies.clearCache ? require './clearCache'

  device = new Device uuid: uuid, dependencies
  device.set params

  device.save (error) =>
    return callback error if error?
    clearCache uuid, =>
      getDevice uuid, callback
