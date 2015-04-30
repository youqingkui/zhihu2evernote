monit = require('../server/monitor')
cookie = process.env.ZhiHu
noteStore = require('../server/noteStore')
async = require('async')



url = 'http://www.zhihu.com/collection/29469118'
m = new monit(url, noteStore, cookie)

async.series [
  (cb) ->
    console.log "here"
    m.getLogPage (err) ->
      return console.log err if err

      cb()

  (cb) ->
    $ = m.$
    m.checkFav $, (err) ->
      return console.log err if err

      cb()

]