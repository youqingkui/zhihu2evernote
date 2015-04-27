// Generated by CoffeeScript 1.8.0
(function() {
  var Evernote, async, changeImg, cheerio, cookie, crypto, encodeImg, fs, getImgRes, getPageCount, makeNote, mime, nodeUrl, noteStore, op, pageImport, reqOp, request, rmAttr;

  request = require('request');

  async = require('async');

  cookie = process.env.ZhiHu;

  cheerio = require('cheerio');

  makeNote = require('./server/createNote');

  noteStore = require('./server/noteStore');

  Evernote = require('evernote').Evernote;

  fs = require('fs');

  crypto = require('crypto');

  mime = require('mime');

  nodeUrl = require('url');

  reqOp = function(url) {
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

  pageImport = function(op, cb) {
    return async.auto({
      getPage: function(c) {
        return request.get(op, function(err, res, body) {
          var $, answerList;
          if (err) {
            return c(err);
          }
          $ = cheerio.load(body);
          answerList = $("#zh-list-answer-wrap > div");
          return c(null, answerList, $);
        });
      },
      getContent: [
        'getPage', function(c, result) {
          var $, answerList, noteArr, oldSourceUrl, oldTitle;
          answerList = result.getPage[0];
          $ = result.getPage[1];
          noteArr = [];
          oldTitle = '';
          oldSourceUrl = '';
          return async.eachSeries(answerList, function(item, callback) {
            var $2, content1, sourceUrl, title, tmp;
            tmp = {};
            title = $(item).find("h2.zm-item-title").text();
            if (!title) {
              title = oldTitle;
            }
            oldTitle = title;
            tmp.title = title;
            sourceUrl = $(item).find("h2.zm-item-title a").attr('href');
            if (!sourceUrl) {
              sourceUrl = oldSourceUrl;
            } else {
              sourceUrl = 'http://www.zhihu.com' + sourceUrl;
            }
            oldSourceUrl = sourceUrl;
            content1 = $(item).find(".content.hidden").text();
            console.log("content1  =====");
            console.log(content1);
            console.log("content1  ===== \n");
            $2 = cheerio.load(content1, {
              decodeEntities: false
            });
            rmAttr($2);
            return changeImg($2, $2("img"), function(err, resourceArr) {
              var content2;
              if (err) {
                return callback(err);
              }
              content2 = $2.html({
                xmlMode: true
              });
              tmp.content = content2;
              tmp.sourceUrl = sourceUrl;
              tmp.resourceArr = resourceArr;
              return makeNote(noteStore, title, content2, sourceUrl, resourceArr, function(err2, note) {
                if (err2) {
                  return callback(err2);
                }
                console.log("create ok " + note.title);
                return callback();
              });
            });
          }, function(eachErr) {
            if (eachErr) {
              return cb(eachErr);
            }
            return c(null, noteArr);
          });
        }
      ]
    }, function(eachErr) {
      if (eachErr) {
        return cb(eachErr);
      }
      return cb();
    });
  };

  rmAttr = function($) {
    return $("a, span, img, i, div, code").removeAttr("class").removeAttr("href").removeAttr('data-rawwidth').removeAttr('data-rawheight').removeAttr('data-original').removeAttr('data-hash').removeAttr('data-editable').removeAttr('data-title').removeAttr('data-tip').removeAttr("eeimg").removeAttr('alt');
  };

  changeImg = function($, $imgs, cb) {
    var resourceArr;
    resourceArr = [];
    return async.eachSeries($imgs, function(item, callback) {
      var eg, src;
      src = $(item).attr('src');
      eg = async.compose(encodeImg, getImgRes);
      return eg(src, function(err, resource) {
        var hexHash, md5, newTag;
        if (err) {
          return console.log(err);
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
    }, function(eachErr) {
      if (eachErr) {
        return console.log(eachErr);
      }
      return cb(null, resourceArr);
    });
  };

  getImgRes = function(imgUrl, cb) {
    var img, imgFile, sUrl;
    sUrl = imgUrl.split('/');
    imgFile = sUrl[sUrl.length - 1];
    img = fs.createWriteStream(imgFile);
    return request.get(imgUrl).on('response', function(res) {
      return console.log(res.statusCode);
    }).on('error', function(err) {
      return console.log(err);
    }).on('end', function() {
      console.log("" + imgUrl + " down ok");
      return cb(null, imgFile);
    }).pipe(img);
  };

  encodeImg = function(img, cb) {
    var data, hash, image, resource;
    image = fs.readFileSync(img);
    hash = image.toString('base64');
    data = new Evernote.Data();
    data.size = image.length;
    data.bodyHash = hash;
    data.body = image;
    resource = new Evernote.Resource();
    resource.mime = mime.lookup(img);
    resource.data = data;
    resource.image = image;
    return cb(null, resource);
  };

  getPageCount = function(url, cb) {
    return request.get(url, function(err, res, body) {
      var $, pageCount, spanArr;
      if (err) {
        return cb(err);
      }
      $ = cheerio.load(body);
      spanArr = $(".zm-invite-pager span");
      pageCount = $(spanArr[spanArr.length - 2]).text();
      return cb(null, Number(pageCount));
    });
  };

  op = reqOp('http://www.zhihu.com/collection/29469118');

  async.auto({
    getPage: function(cb) {
      return getPageCount(op, function(err, count) {
        if (err) {
          return cb(err);
        }
        console.log("count", count);
        return cb(null, count);
      });
    },
    importPage: [
      'getPage', function(cb, result) {
        var pageArr, pageCount, _i, _results;
        pageCount = result.getPageCount;
        pageArr = [0].concat((function() {
          _results = [];
          for (var _i = 2; 2 <= pageCount ? _i <= pageCount : _i >= pageCount; 2 <= pageCount ? _i++ : _i--){ _results.push(_i); }
          return _results;
        }).apply(this));
        return async.eachSeries(pageArr, function(item, callback) {
          var newUrl, op2;
          if (item === !0) {
            newUrl = op.url + '?page' + item;
            op2 = reqOp(newUrl);
          } else {
            op2 = op;
          }
          return pageImport(op2, function(err, result) {
            if (err) {
              return cb(err);
            }
            console.log("" + newUrl + " is import ok");
            return callback();
          });
        }, function(eachErr) {
          if (eachErr) {
            return console.log(eachErr);
          }
          return console.log("all page do !!");
        });
      }
    ]
  });

}).call(this);

//# sourceMappingURL=app.js.map
