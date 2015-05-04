// Generated by CoffeeScript 1.8.0
(function() {
  var GetCol, fs, path, queue, requrest;

  requrest = require('request');

  fs = require('fs');

  path = require('path');

  queue = require('../server/getAnswers');

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
      return requrest.get(op, function(err, res, body) {
        var data, i, _i, _len, _ref;
        if (err) {
          return console.log(err);
        }
        data = JSON.parse(body);
        if (data.data.length) {
          _ref = data.data;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            i = _ref[_i];
            console.log("" + i.url + " add queue, queue ==> " + (queue.length()));
            queue.push({
              url: i.url,
              noteStore: self.noteStore
            }, function() {
              return console.log("do ok ==>", i.url);
            });
          }
          return self.getColList(data.paging.next);
        } else {
          return console.log(data);
        }
      });
    };

    GetCol.prototype.getColInfo = function() {};

    return GetCol;

  })();

  module.exports = GetCol;

}).call(this);

//# sourceMappingURL=getCollection.js.map
