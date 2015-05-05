// Generated by CoffeeScript 1.8.0
(function() {
  var GetCol, SyncLog, async, fs, path, queue, requrest, saveErr;

  requrest = require('request');

  fs = require('fs');

  path = require('path');

  queue = require('../server/getAnswers');

  SyncLog = require('../models/sync-log');

  async = require('async');

  saveErr = require('../server/errInfo');

  GetCol = (function() {
    function GetCol(noteStore) {
      this.noteStore = noteStore;
      this.headers = {
        'User-Agent': 'osee2unifiedRelease/332 CFNetwork/711.3.18 Darwin/14.0.0',
        'Authorization': 'oauth 5774b305d2ae4469a2c9258956ea49',
        'Content-Type': 'application/json'
      };
    }

    GetCol.prototype.getColList = function(url) {
      var op, self;
      self = this;
      op = {
        url: url,
        headers: self.headers,
        gzip: true
      };
      return async.auto({
        getList: function(cb) {
          return requrest.get(op, function(err, res, body) {
            var data;
            if (err) {
              return saveErr(op.url, 1, {
                err: err
              });
            }
            data = JSON.parse(body);
            return cb(null, data);
          });
        },
        checkList: [
          'getList', function(cb, result) {
            var answerList, data;
            data = result.getList;
            if (data.data.length) {
              answerList = data.data;
              answerList.forEach(function(answer) {
                return SyncLog.findOne({
                  href: answer.url
                }, function(err, row) {
                  if (err) {
                    return saveErr(url, 2, {
                      err: err,
                      answer: answer.url
                    });
                  }
                  if (!row) {
                    console.log("" + answer.url + " add queue, queue ==> " + (queue.length()));
                    return queue.push({
                      url: answer.url,
                      noteStore: self.noteStore
                    }, function(err) {
                      if (err) {
                        return console.log("" + answer.url + " do has err:" + err + " 剩余队列数" + (queue.length()));
                      }
                      return console.log("do ok " + answer.url + " 剩余队列数:" + (queue.length()));
                    });
                  } else {
                    return console.log("already exits ==>", answer.url);
                  }
                });
              });
              return self.getColList(data.paging.next);
            } else {
              return console.log(data);
            }
          }
        ]
      });
    };

    GetCol.prototype.getColInfo = function() {};

    return GetCol;

  })();

  module.exports = GetCol;

}).call(this);

//# sourceMappingURL=getCollection.js.map
