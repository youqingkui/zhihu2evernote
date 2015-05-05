// Generated by CoffeeScript 1.8.0
(function() {
  var GetCol, SyncLog, Task, async, fs, path, queue, requrest, saveErr;

  requrest = require('request');

  fs = require('fs');

  path = require('path');

  queue = require('../server/getAnswers');

  SyncLog = require('../models/sync-log');

  async = require('async');

  saveErr = require('../server/errInfo');

  Task = require('../models/task');

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
                return Task.findOne({
                  url: answer.url
                }, function(err, row) {
                  if (err) {
                    return saveErr(url, 2, {
                      err: err,
                      answer: answer.url
                    });
                  }
                  if (row) {
                    return console.log("already exits ==>", url);
                  } else {
                    return self.addTask(url, function(err2) {});
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

    GetCol.prototype.checkTask = function(url, cb) {
      var self;
      self = this;
      return Task.findOne({
        url: url
      }, function(err, row) {
        if (err) {
          return cb(err);
        }
        if (row) {
          return console.log("already exits ==>", url);
        } else {
          return self.addTask(url, cb);
        }
      });
    };

    GetCol.prototype.addTask = function(url, cb) {
      var self;
      self = this;
      return queue.push({
        url: url,
        noteStore: self.noteStore
      }, function(err) {
        if (err) {
          console.log(err);
          return self.changeStatus(url, 2, cb);
        } else {
          return self.changeStatus(url, 3, cb);
        }
      });
    };

    GetCol.prototype.changeStatus = function(url, status, cb) {
      return async.auto({
        findUrl: function(callback) {
          return Task.findOne({
            url: url
          }, function(err, row) {
            if (err) {
              return cb(err);
            }
            if (row) {
              return callback(null, row);
            }
          });
        },
        change: [
          'findUrl', function(callback, result) {
            var row;
            row = result.findUrl;
            row.status = status;
            return row.save(function(err, row) {
              if (err) {
                return cb(err);
              }
              return cb();
            });
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
