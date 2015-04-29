// Generated by CoffeeScript 1.8.0
(function() {
  var Monitor, async, cheerio, cookie, noteStore, queue, request;

  request = require('request');

  cheerio = require('cheerio');

  async = require('async');

  cookie = process.env.ZhiHu;

  queue = require('../server/queue');

  noteStore = require('../server/noteStore');

  Monitor = (function() {
    function Monitor(colUrl, noteStore, cookie) {
      this.colUrl = colUrl;
      this.noteStore = noteStore;
      this.cookie = cookie;
      this.$ = null;
      this._xsrf = '';
    }

    Monitor.prototype.getLogPage = function(cb) {
      var op, self;
      self = this;
      op = self.reqOp(self.colUrl + '/log');
      return request.get(op, function(err, res, body) {
        var $;
        if (err) {
          return cb(err);
        }
        $ = cheerio.load(body, {
          decodeEntities: false
        });
        self.$ = $;
        self._xsrf = self.$("input[name='_xsrf']").val();
        return cb();
      });
    };

    Monitor.prototype.checkFav = function($, cb) {
      var favDivList, favList, self, start, startID, startNum;
      self = this;
      favDivList = $("div.zm-item");
      start = favDivList[favDivList.length - 1];
      startID = $(start).attr('id');
      startNum = startID.split('-')[1];
      favList = $("div.zm-item ins > a");
      favList.each(function(i, elem) {
        var href;
        href = 'http://www.zhihu.com' + $(elem).attr('href');
        console.log("add task", href);
        return queue.push({
          url: href,
          noteStore: noteStore,
          cookie: cookie
        }, function(err) {
          if (err) {
            return console.log(err);
          }
        });
      });
      return self.repeatDo(startNum, cb);
    };

    Monitor.prototype.repeatDo = function(start, cb) {
      var op, self;
      self = this;
      op = self.reqOp(self.colUrl + '/log');
      op.form = {
        start: start,
        _xsrf: self._xsrf
      };
      return request.post(op, function(err, res, body) {
        var $, data;
        if (err) {
          return cb(err);
        }
        data = JSON.parse(body);
        console.log(data);
        if (data.msg[0] !== 0) {
          $ = cheerio.load(data.msg[1]);
          return self.checkFav($, cb);
        } else {
          console.log("==================================================");
          console.log("stop here", start);
          console.log("==================================================");
          return cb();
        }
      });
    };

    Monitor.prototype.reqOp = function(url) {
      var options;
      options = {
        url: url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36',
          'Cookie': cookie
        }
      };
      return options;
    };

    return Monitor;

  })();

  module.exports = Monitor;

}).call(this);

//# sourceMappingURL=monitor.js.map
