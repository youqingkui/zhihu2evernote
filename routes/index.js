// Generated by CoffeeScript 1.8.0
(function() {
  var Evernote, callbackUrl, config, express, router;

  express = require('express');

  router = express.Router();

  Evernote = require('evernote').Evernote;

  config = require('../config.json');

  callbackUrl = "http://localhost:3000/oauth_callback";


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
    var client, oauthToken, oauthTokenSecret, oauth_verifier;
    client = new Evernote.Client({
      consumerKey: config.API_CONSUMER_KEY,
      consumerSecret: config.API_CONSUMER_SECRET,
      sandbox: config.SANDBOX
    });
    oauthToken = req.query.oauth_token;
    oauthTokenSecret = req.session.oauthTokenSecret;
    oauth_verifier = req.query.oauth_verifier;
    return client.getAccessToken(oauthToken, oauthTokenSecret, oauth_verifier, function(err, oauthAccessToken, oauthAccessTokenSecret, results) {
      if (err) {
        if (err) {
          return console.log("err", err);
        }
      }
      console.log("oauthAccessToken =>", oauthAccessToken);
      console.log("oauthAccessTokenSecret =>", oauthAccessTokenSecret);
      return console.log("results =>", results);
    });
  });

  router.get('/user/:token', function(req, res) {
    var client, token, userStore;
    token = req.params.token;
    client = new Evernote.Client({
      token: token
    });
    userStore = client.getUserStore();
    return userStore.getUser(function(err, user) {
      if (err) {
        return console.log(err);
      }
      return console.log(user);
    });
  });

  module.exports = router;

}).call(this);

//# sourceMappingURL=index.js.map
