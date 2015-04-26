// Generated by CoffeeScript 1.8.0
(function() {
  var Evernote, async, changeImg, cheerio, cookie, crypto, encodeImg, fs, getImgRes, makeNote, mime, noteStore, op, reqOp, request;

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

  op = reqOp('http://www.zhihu.com/collection/29469118?page=9');

  request.get(op, function(err, res, body) {
    var $, answerList, oldTitle;
    if (err) {
      return console.log(err);
    }
    $ = cheerio.load(body, {});
    answerList = $("#zh-list-answer-wrap > div");
    oldTitle = '';
    return async.eachSeries(answerList, function(item, callback) {
      var $2, content1, title;
      title = $(item).find("h2.zm-item-title").text();
      if (!title) {
        title = oldTitle;
      }
      oldTitle = title;
      content1 = $(item).find(".content.hidden").text();
      console.log("content1  =====");
      console.log(content1);
      console.log("content1  ===== \n");
      $2 = cheerio.load(content1, {
        decodeEntities: false
      });
      $2("a, span, img, i, div, code").removeAttr("class").removeAttr("href").removeAttr('data-rawwidth').removeAttr('data-rawheight').removeAttr('data-original').removeAttr('data-hash').removeAttr('data-editable').removeAttr('data-title').removeAttr('data-tip').removeAttr("eeimg").removeAttr('alt');
      return changeImg($2, $2("img"), function(err, resourceArr) {
        var content2;
        content2 = $2.html({
          xmlMode: true
        });
        console.log("content2 ======");
        console.log(content2);
        console.log("content2 ======");
        return makeNote(noteStore, title, content2, 'http://www.zhihu.com/collection/29469118', resourceArr, function(err1, note) {
          if (err1) {
            return console.log(err1);
          }
          return console.log(note);
        });
      });
    }, function(eachErr) {
      if (eachErr) {
        return console.log(eachErr);
      }
    });
  });

  changeImg = function($, $imgs, cb) {
    var resourceArr;
    console.log("changeImg here +++++");
    resourceArr = [];
    return async.eachSeries($imgs, function(item, callback) {
      var eg, src;
      src = $(item).attr('src');
      console.log(src);
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

}).call(this);

//# sourceMappingURL=app.js.map
