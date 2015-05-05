requrest = require('request')
fs = require('fs')
path = require('path')
queue = require('../server/getAnswers')
SyncLog = require('../models/sync-log')
async = require('async')
saveErr = require('../server/errInfo')



class GetCol
  constructor:(@noteStore) ->
    @headers = {
      'User-Agent':'osee2unifiedRelease/332 CFNetwork/711.3.18 Darwin/14.0.0'
      'Authorization':'oauth 5774b305d2ae4469a2c9258956ea49'
      'Content-Type':'application/json'
    }



  getColList:(url) ->
    self = @
    op = {
      url:url
      headers:self.headers
      gzip:true
    }

    async.auto
      getList:(cb) ->
        requrest.get op, (err, res, body) ->
          return saveErr op.url, 1, {err:err} if err

          data = JSON.parse(body)
          cb(null, data)

      checkList:['getList', (cb, result) ->
        data = result.getList
        if data.data.length
          answerList = data.data
          answerList.forEach (answer) ->
            SyncLog.findOne {href:answer.url}, (err, row) ->
              return saveErr url, 2, {err:err, answer:answer.url} if err

              if not row
                console.log "#{answer.url} add queue, queue ==> #{queue.length()}"
                queue.push {url:answer.url, noteStore:self.noteStore}, () ->
                  console.log "do ok ==>", answer.url

              else
                console.log "already exits ==>", answer.url


          self.getColList(data.paging.next)

        else
          console.log data

      ]


  getColInfo:() ->


module.exports = GetCol
