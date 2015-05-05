mongoose = require('./mongoose')

SyncLogSchema = mongoose.Schema
  title:String
  created:Number
  updated:Number
  tagNames:Array
  href:String

module.exports = mongoose.model('SyncLog', SyncLogSchema)