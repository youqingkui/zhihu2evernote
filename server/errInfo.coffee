ErrLog = require('../models/err-log')
email = require('./email')()


saveErr = (href, type, info, cb) ->
  console.log info

  log = new ErrLog()
  log.href = href
  log.type = type
  log.info = info

  log.save (err, row) ->
    return console.log err if err

  emailBody = JSON.stringify(log)
  email.send(emailBody)

  if cb
    cb(info)



module.exports = saveErr


