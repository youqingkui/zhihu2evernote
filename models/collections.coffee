mongoose = require('./mongoose')

CollectionsSchema = mongoose.Schema
  username:String
  created:Number
  type:Number
  url:String


module.exports = mongoose.model('Collections', CollectionsSchema)