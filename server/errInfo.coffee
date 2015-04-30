ErrLog = require('../models/err-log')
email = require('./email')()


saveErr = (href, type, infoJson, cb) ->
  console.log infoJson.err

  log = new ErrLog()
  log.href = href
  log.type = type
  log.info = JSON.stringify(infoJson)

  log.save (err, row) ->
    return console.log err if err

  emailBody = JSON.stringify(log)
  email.send(emailBody)

  if cb
    cb(infoJson.err)



module.exports = saveErr


