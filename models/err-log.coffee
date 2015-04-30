mongoose = require('./mongoose')

ErrLogSchema = mongoose.Schema
  title:String
  created:Number
  href:String
  type:Number
  info:String

module.exports = mongoose.model('ErrLog', ErrLogSchema)