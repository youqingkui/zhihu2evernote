mongoose = require('./mongoose')

UserSchema = mongoose.Schema
  username:{type:String, unique: true}
  created:Number
  type:Number
  info:String
  password:String
  salt:String
  email:{type:String, unique: true}
  oauthAccessToken:String
  edamShard:String
  edamUserId:String
  edamExpires:Number
  edamNoteStoreUrl:String
  edamWebApiUrlPrefix:String


module.exports = mongoose.model('User', UserSchema)