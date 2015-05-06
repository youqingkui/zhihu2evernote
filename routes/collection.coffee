express = require('express')
router = express.Router()
async = require('async')

Collections = require('../models/collections')


router.get '/', (req, res) ->
  username = req.session.username
  Collections.find {username:username}, (err, rows) ->
    return console.log err if err

    console.log rows


router.get '/add/:url', (req, res) ->
  username = req.session.username
  url = req.params.url

  async.auto
    checkExits:(cb) ->
      Collections.findOne {url:url}, (err, row) ->
        return console.log err if err

        if row
          return res.send "aleary exits this url:#{url}"

        else
          cb()


    addUrl:['checkExits', (cb) ->
      col = new Collection()
      col.username = username
      col.url = url
      col.created = Date.now()
      col.type = 1
      col.save (err, row) ->
        return console.log err if err

        return res.send "add ok"

    ]















module.exports = router

