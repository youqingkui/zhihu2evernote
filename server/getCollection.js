// Generated by CoffeeScript 1.8.0
(function() {
  var GetCol, certFile, fs, keyFile, path, requrest;

  requrest = require('request');

  fs = require('fs');

  path = require('path');

  certFile = path.resolve(__dirname, 'zhihu.crt');

  keyFile = path.resolve(__dirname, 'zhihu.key');

  GetCol = (function() {
    function GetCol(url) {
      this.url = url;
      this.headers = {
        'User-Agent': 'osee2unifiedRelease/332 CFNetwork/711.3.18 Darwin/14.0.0',
        'Authorization': 'oauth 5774b305d2ae4469a2c9258956ea49',
        'Content-Type': 'application/json'
      };
    }

    GetCol.prototype.getColList = function() {
      var op, self, url;
      self = this;
      url = self.url + 'answers';
      op = {
        url: url,
        headers: self.headers,
        gzip: true
      };
      return requrest.get(op, function(err, res, body) {
        var data;
        if (err) {
          return console.log(err);
        }
        data = JSON.parse(body);
        return console.log(data.data[0]);
      });
    };

    GetCol.prototype.getColInfo = function() {};

    return GetCol;

  })();

  module.exports = GetCol;

}).call(this);

//# sourceMappingURL=getCollection.js.map
