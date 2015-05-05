mongoose = require('./mongoose')

TaskSchema = mongoose.Schema
  url:String
  status:{type:Number, default:1}

module.exports = mongoose.model('Task', TaskSchema)