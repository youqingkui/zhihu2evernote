express = require('express')
router = express.Router()
Evernote = require('evernote').Evernote
config = require('../config.json')
callbackUrl = "http://localhost:3000/oauth_callback"

### GET home page. ###

router.get '/', (req, res, next) ->
  res.render 'index', title: 'Express'
  return

router.get '/oauth', (req, res) ->
  client = new Evernote.Client
    consumerKey: config.API_CONSUMER_KEY
    consumerSecret: config.API_CONSUMER_SECRET
    sandbox: config.SANDBOX


  client.getRequestToken callbackUrl, (err, oauthToken, oauthTokenSecret, result) ->
    return console.log err if err

    console.log "result =>",result

    console.log "oauthToken =>", oauthToken

    console.log "oauthTokenSecret =>", oauthTokenSecret

    req.session.oauthTokenSecret = oauthTokenSecret

    return res.redirect(client.getAuthorizeUrl(oauthToken))


router.get '/oauth_callback', (req, res) ->
  client = new Evernote.Client
    consumerKey: config.API_CONSUMER_KEY,
    consumerSecret: config.API_CONSUMER_SECRET,
    sandbox: config.SANDBOX

  oauthToken = req.query.oauth_token
  oauthTokenSecret = req.session.oauthTokenSecret
  oauth_verifier = req.query.oauth_verifier

  client.getAccessToken oauthToken, oauthTokenSecret, oauth_verifier,
    (err, oauthAccessToken, oauthAccessTokenSecret, results) ->
      if err
        return console.log "err", err if err

      console.log "oauthAccessToken =>", oauthAccessToken
      console.log "oauthAccessTokenSecret =>", oauthAccessTokenSecret
      console.log "results =>", results


router.get '/user/:token', (req, res) ->
  token = req.params.token
  client = new Evernote.Client
    token:token

  userStore = client.getUserStore()
  userStore.getUser (err, user) ->
    return console.log err if err

    console.log user



module.exports = router

