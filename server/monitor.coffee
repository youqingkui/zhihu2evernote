SyncLog = require('../models/sync-log')
request = require('request')
cheerio = require('cheerio')
async = require('async')
cookie = process.env.ZhiHu
queue = require('../server/queue')
noteStore = require('../server/noteStore')
saveErr = require('../server/errInfo')




class Monitor
  constructor: (@colUrl, @noteStore, @cookie) ->
    @$ = null
    @_xsrf = ''
    @offset = 0


  getLogPage: (cb) ->
    self = @
    op = self.reqOp(self.colUrl + '/log')
    request.get op, (err, res, body) ->
      return saveErr(self.colUrl, 1, {err:err}, cb) if err
      $ = cheerio.load body, {decodeEntities: false}
      self.$ = $
      self._xsrf = self.$("input[name='_xsrf']").val()

      cb()

  checkFav: ($ , cb) ->
    self = @

    favDivList = $("div.zm-item")
    start = favDivList[favDivList.length - 1]
    startID = $(start).attr('id')
    startNum = startID.split('-')[1]

    favList = $("div.zm-item ins > a")
    favList.each (i, elem) ->
      href = 'http://www.zhihu.com' + $(elem).attr('href')
      SyncLog.findOne {'href':href}, (err, row) ->
        console.log err if err
        if not row and href != self.colUrl
          console.log "add task", href
          console.log('waiting tasks: ', queue.length())
          queue.push {url:href, noteStore:noteStore, cookie:cookie},
            (err) ->
#              return console.log err if err
        else
          console.log "aleary sync this", href

    self.repeatDo startNum, cb


  repeatDo: (start, cb) ->
    self = @
    op = self.reqOp(self.colUrl + '/log')
    self.offset += 20
    op.form = {start:start, _xsrf:self._xsrf, offset:self.offset}
    request.post op, (err, res, body) ->
      return saveErr(op.url, 2, err, cb) if err

      try
        data = JSON.parse(body)
      catch err
        saveErr(op.url, 3, {body:body, start:start})
        return cb()

      console.log "data.msg[0]", data.msg[0]
      if data.msg[0] != 0
        $ = cheerio.load(data.msg[1])
        self.checkFav $, cb

      else
        console.log "=================================================="
        console.log "stop here", start, self.offset
        console.log "=================================================="

        cb()



  reqOp: (url) ->
    options =
      url:url
      headers:
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36',
        'Cookie':cookie

    return options





module.exports = Monitor








