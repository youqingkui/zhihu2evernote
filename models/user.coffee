mongoose = require('./mongoose')

UserSchema = mongoose.Schema
  name:String
  created:Number
  token:String
  type:Number
  info:String

module.exports = mongoose.model('User', UserSchema)