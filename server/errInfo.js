// Generated by CoffeeScript 1.8.0
(function() {
  var ErrLog, email, saveErr;

  ErrLog = require('../models/err-log');

  email = require('./email')();

  saveErr = function(href, type, info, cb) {
    var emailBody, log;
    console.log(info);
    log = new ErrLog();
    log.href = href;
    log.type = type;
    log.info = info;
    log.save(function(err, row) {
      if (err) {
        return console.log(err);
      }
    });
    emailBody = JSON.stringify(log);
    email.send(emailBody);
    if (cb) {
      return cb(info);
    }
  };

  module.exports = saveErr;

}).call(this);

//# sourceMappingURL=errInfo.js.map
