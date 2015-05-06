// Generated by CoffeeScript 1.8.0
(function() {
  var Evernote, User, async, callbackUrl, config, createNote, crypto, express, md5, router;

  express = require('express');

  router = express.Router();

  Evernote = require('evernote').Evernote;

  config = require('../config.json');

  callbackUrl = "http://localhost:3000/oauth_callback";

  User = require('../models/user');

  async = require('async');

  createNote = require('../server/createAccount');

  crypto = require('crypto');

  md5 = function(str) {
    var md5sum;
    md5sum = crypto.createHash('md5');
    md5sum.update(str);
    str = md5sum.digest('hex');
    return str;
  };


  /* GET home page. */

  router.get('/', function(req, res, next) {
    res.render('index', {
      title: 'Express'
    });
  });

  router.get('/oauth', function(req, res) {
    var client;
    client = new Evernote.Client({
      consumerKey: config.API_CONSUMER_KEY,
      consumerSecret: config.API_CONSUMER_SECRET,
      sandbox: config.SANDBOX
    });
    return client.getRequestToken(callbackUrl, function(err, oauthToken, oauthTokenSecret, result) {
      if (err) {
        return console.log(err);
      }
      console.log("result =>", result);
      console.log("oauthToken =>", oauthToken);
      console.log("oauthTokenSecret =>", oauthTokenSecret);
      req.session.oauthTokenSecret = oauthTokenSecret;
      return res.redirect(client.getAuthorizeUrl(oauthToken));
    });
  });

  router.get('/oauth_callback', function(req, res) {
    var client, oauthToken, oauthTokenSecret, oauth_verifier, resInfo, token, username;
    client = new Evernote.Client({
      consumerKey: config.API_CONSUMER_KEY,
      consumerSecret: config.API_CONSUMER_SECRET,
      sandbox: config.SANDBOX
    });
    oauthToken = req.query.oauth_token;
    oauthTokenSecret = req.session.oauthTokenSecret;
    oauth_verifier = req.query.oauth_verifier;
    token = '';
    resInfo = null;
    username = '';
    return async.auto({
      checkOauth: function(cb) {
        return client.getAccessToken(oauthToken, oauthTokenSecret, oauth_verifier, function(err, oauthAccessToken, oauthAccessTokenSecret, results) {
          if (err) {
            if (err) {
              return res.send("oauth err");
            }
          }
          console.log("oauthAccessToken =>", oauthAccessToken);
          console.log("oauthAccessTokenSecret =>", oauthAccessTokenSecret);
          console.log("results =>", results);
          token = oauthAccessToken;
          resInfo = results;
          return cb();
        });
      },
      getUserInfo: [
        'checkOauth', function(cb, result) {
          var c, userStore;
          c = new Evernote.Client({
            token: token
          });
          userStore = c.getUserStore();
          return userStore.getUser(function(err, user) {
            if (err) {
              return console.log(err);
            }
            return cb(null, user);
          });
        }
      ],
      checkUser: [
        'getUserInfo', function(cb, result) {
          username = result.getUserInfo.username;
          return User.findOne({
            username: username
          }, function(err, row) {
            if (err) {
              return console.log(err);
            }
            return cb(null, row);
          });
        }
      ],
      comUser: [
        'checkUser', function(cb, result) {
          var user;
          user = result.checkUser;
          if (user) {
            user.oauthAccessToken = token;
            user.edamShard = resInfo.edamShard;
            user.edamUserId = resInfo.edamUserId;
            user.edamExpires = resInfo.edamExpires;
            user.edamNoteStoreUrl = resInfo.edamNoteStoreUrl;
            user.edamWebApiUrlPrefix = resInfo.edamWebApiUrlPrefix;
            return user.save(function(err, row) {
              if (err) {
                return console.log(err);
              }
              return res.send("up ok");
            });
          } else {
            return cb();
          }
        }
      ],
      createUser: [
        'comUser', function(cb) {
          var c, newUser, noteStore, pwd, salt;
          pwd = Math.random().toString(36).substr(2);
          salt = Math.random().toString(36).substr(2);
          newUser = new User();
          newUser.username = username;
          newUser.oauthAccessToken = token;
          newUser.edamShard = resInfo.edamShard;
          newUser.edamUserId = resInfo.edamUserId;
          newUser.edamExpires = resInfo.edamExpires;
          newUser.edamNoteStoreUrl = resInfo.edamNoteStoreUrl;
          newUser.edamWebApiUrlPrefix = resInfo.edamWebApiUrlPrefix;
          newUser.salt = salt;
          newUser.password = md5(pwd + salt);
          c = new Evernote.Client({
            token: token
          });
          noteStore = c.getNoteStore();
          return createNote(noteStore, 'zhihu2evernote', pwd, function(err, note) {
            if (err) {
              return console.log(err);
            }
            return newUser.save(function(err2, row) {
              if (err2) {
                return console.log(err2);
              }
              return res.send("create ok");
            });
          });
        }
      ]
    });
  });

  router.get('/user/', function(req, res) {
    return User.findOne({
      username: 'youqingkui'
    }, function(err, row) {
      if (err) {
        return console.log(err);
      }
      console.log(row);
      return res.send(row);
    });
  });

  router.get('/test_login', function(req, res) {
    req.session.username = 'youqingkui';
    return res.send("ok login");
  });

  module.exports = router;

}).call(this);

//# sourceMappingURL=index.js.map
