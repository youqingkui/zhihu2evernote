express = require('express')
router = express.Router()
Evernote = require('evernote').Evernote
config = require('../config.json')
callbackUrl = "http://localhost:3000/oauth_callback"
User = require('../models/user')
async = require('async')
createNote = require('../server/createAccount')
crypto = require('crypto')


md5 = (str) ->
  md5sum = crypto.createHash('md5')
  md5sum.update(str)
  str = md5sum.digest('hex')
  return str

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

  token = ''
  resInfo = null
  username = ''

  async.auto
    # 验证信息
    checkOauth:(cb) ->
      client.getAccessToken oauthToken, oauthTokenSecret, oauth_verifier,
        (err, oauthAccessToken, oauthAccessTokenSecret, results) ->
          if err
            return res.send "oauth err" if err

          console.log "oauthAccessToken =>", oauthAccessToken
          console.log "oauthAccessTokenSecret =>", oauthAccessTokenSecret
          console.log "results =>", results

          token = oauthAccessToken
          resInfo = results
          cb()

    # 获取用户信息
    getUserInfo:['checkOauth', (cb, result) ->
      c = new Evernote.Client
        token:token
      userStore = c.getUserStore()
      userStore.getUser (err, user) ->
        return console.log err if err

        cb(null, user)
    ]
    # 检查用户是否存在
    checkUser:['getUserInfo', (cb, result) ->
      username = result.getUserInfo.username
      User.findOne {username:username}, (err, row) ->
        return console.log err if err

        cb(null, row)
    ]

    # 修改用户信息
    comUser:['checkUser', (cb, result) ->
      user = result.checkUser
      if user
        user.oauthAccessToken = token
        user.edamShard = resInfo.edamShard
        user.edamUserId = resInfo.edamUserId
        user.edamExpires = resInfo.edamExpires
        user.edamNoteStoreUrl = resInfo.edamNoteStoreUrl
        user.edamWebApiUrlPrefix = resInfo.edamWebApiUrlPrefix
        user.save (err, row) ->
          return console.log err if err

          return res.send "up ok"

      else
        cb()

    ]

    # 创建用户
    createUser:['comUser', (cb) ->
      pwd = Math.random().toString(36).substr(2)
      salt = Math.random().toString(36).substr(2)
      newUser = new User()
      newUser.username = username
      newUser.oauthAccessToken = token
      newUser.edamShard = resInfo.edamShard
      newUser.edamUserId = resInfo.edamUserId
      newUser.edamExpires = resInfo.edamExpires
      newUser.edamNoteStoreUrl = resInfo.edamNoteStoreUrl
      newUser.edamWebApiUrlPrefix = resInfo.edamWebApiUrlPrefix
      newUser.salt = salt
      newUser.password = md5(pwd + salt)

      c = new Evernote.Client({token: token})
      noteStore = c.getNoteStore()
      createNote noteStore, 'zhihu2evernote', pwd, (err, note) ->
        return console.log err if err

        newUser.save (err2, row) ->
          return console.log err2 if err2

          return res.send "create ok"
    ]




router.get '/login', (req, res) ->
  console.log req.session.username
  return res.render 'login', {title:'登录', username:''}

router.post '/login', (req, res) ->
  username = (req.body.username || '').trim()
  password = (req.body.password || '').trim()

  async.auto
    findUser:(cb) ->
      User.findOne {username:username}, (err, row) ->
        return console.log err if err

        if not row
          error = "没有此用户或者密码错误"
          return res.render 'login',
            {title:'登入', error:error, username:username}

        cb(null, row)

    checkPWD:['findUser', (cb, result) ->
      user = result.findUser
      md5Pwd = md5(password + user.salt)
      if md5Pwd != user.password
        error = "密码错误"
        return res.render 'login',
          {title:'登入', error:error, username:username}

      req.session.username = user.username
      return res.redirect('/')
    ]


router.get '/user/', (req, res) ->
  User.findOne {username:'youqingkui'}, (err, row) ->
    return console.log err if err

    console.log row
    res.send row


router.get '/test_login', (req, res) ->
  req.session.username = 'youqingkui'
  return res.send "ok login"



module.exports = router

