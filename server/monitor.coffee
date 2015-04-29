#SyncLog = require('../models/sync-log')
request = require('request')
cheerio = require('cheerio')
async = require('async')
cookie = process.env.ZhiHu
queue = require('../server/queue')
noteStore = require('../server/noteStore')




class Monitor
  constructor: (@colUrl, @noteStore, @cookie) ->
    @$ = null
    @_xsrf = ''




  getLogPage: (cb) ->
    self = @
    op = self.reqOp(self.colUrl + '/log')
    request.get op, (err, res, body) ->
      return cb(err) if err
      $ = cheerio.load body, {decodeEntities: false}
      console.log body
      self.$ = $
      cb()

  checkFav: (cb) ->
    self = @
    self._xsrf = self.$("input[name='_xsrf']").val()
    favDivList = self.$("div.zm-item")
    favList = self.$("div.zm-item ins > a")
    favList.each (i, elem) ->
      href = 'http://www.zhihu.com' + self.$(elem).attr('href')
      queue.push {url:href, noteStore:noteStore, cookie:cookie},
        (err) ->
          return console.log err if err

    cb()

  reqOp: (url) ->
    options =
      url:url
      headers:
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36',
        'Cookie':cookie

    return options





module.exports = Monitor








