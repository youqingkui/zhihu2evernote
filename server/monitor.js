// Generated by CoffeeScript 1.8.0
(function() {
  var Monitor, SyncLog, async, cheerio, makeNote, request;

  SyncLog = require('../models/sync-log');

  request = require('request');

  cheerio = require('cheerio');

  async = require('async');

  makeNote = require('./createNote');

  Monitor = (function() {
    function Monitor(colUrl, noteStore, cookie) {
      this.colUrl = colUrl;
      this.noteStore = noteStore;
      this.cookie = cookie;
      this.$ = null;
      this._xsrf = '';
    }

    Monitor.prototype.compleStatus = function() {};

    Monitor.prototype.getLogPage = function(cb) {
      var self;
      self = this;
      return request.get(self.colUrl + '/log', function(err, res, body) {
        var $;
        if (err) {
          return cb(err);
        }
        $ = cheerio.load(body);
        self.$ = $;
        return cb();
      });
    };

    Monitor.prototype.checkFav = function(cb) {
      var favDivList, favList, self;
      self = this;
      self._xsrf = self.$("input[name='_xsrf']").val();
      favDivList = self.$("div.zm-item");
      return favList = self.$("div.zm-item ins > a");
    };

    Monitor.prototype.createNote = function(noteStore, title, tags, content, soureUrl, resArr, cb) {
      return makeNote(noteStore, title, tags, content, soureUrl, resArr, function(err, note) {
        if (err) {
          return cb(err);
        }
        console.log("note " + note.title + " create ok");
        return cb();
      });
    };

    Monitor.prototype.getFavContenr = function(favUrl, cb) {
      return request.get(favUrl, function(err, res, body) {
        var $, content, tagArr, tagList, timeInfo;
        if (err) {
          return cb(err);
        }
        $ = cheerio.load(body);
        tagArr = [];
        tagList = $("a.zm-item-tag");
        tagList.each(function(i, elem) {
          var tagName;
          tagName = $(elem).text().trim();
          return tagArr.push(tagName);
        });
        content = $("#zh-question-answer-wrap .zm-editable-content").text();
        timeInfo = $("#zh-question-answer-wrap span.answer-date-link-wrap").text();
        content += timeInfo;
        return cb(null, content);
      });
    };

    Monitor.prototype.changeContent = function(content, cb) {
      var $, imgs, resourceArr;
      $ = cheerio.load(content);
      $("a, span, img, i, div, code").map(function(i, elem) {
        var k, _results;
        _results = [];
        for (k in elem.attribs) {
          if (k !== 'src') {
            _results.push($(this).removeAttr(k));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      });
      imgs = $("img");
      resourceArr = [];
      return async.each(imgs, function(item, callback) {
        var src;
        src = $(item).attr('src');
        return readImgRes(src, function(err, resource) {
          var hexHash, md5, newTag;
          if (err) {
            return cb(err);
          }
          resourceArr.push(resource);
          md5 = crypto.createHash('md5');
          md5.update(resource.image);
          hexHash = md5.digest('hex');
          newTag = "<en-media type=" + resource.mime + " hash=" + hexHash + " />";
          console.log(newTag);
          $(item).replaceWith(newTag);
          return callback();
        });
      }, function() {
        var changeContent;
        changeContent = $.html({
          xmlMode: true
        });
        return cb(null, changeContent, resourceArr);
      });
    };

    Monitor.prototype.readImgRes = function(imgUrl, cb) {
      var op;
      op = reqOp(imgUrl);
      op.encoding = 'binary';
      return async.auto({
        readImg: function(callback) {
          return request.get(op, function(err, res, body) {
            var mimeType;
            if (err) {
              return cb(err);
            }
            mimeType = res.headers['content-type'];
            return callback(null, body, mimeType);
          });
        },
        enImg: [
          'readImg', function(callback, result) {
            var data, hash, image, mimeType, resource;
            mimeType = result.readImg[1];
            image = new Buffer(result.readImg[0], 'binary');
            hash = image.toString('base64');
            data = new Evernote.Data();
            data.size = image.length;
            data.bodyHash = hash;
            data.body = image;
            resource = new Evernote.Resource();
            resource.mime = mimeType;
            resource.data = data;
            resource.image = image;
            return cb(null, resource);
          }
        ]
      });
    };

    return Monitor;

  })();

}).call(this);

//# sourceMappingURL=monitor.js.map