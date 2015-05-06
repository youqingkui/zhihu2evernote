requrest = require('request')
fs = require('fs')
path = require('path')
queue = require('../server/getAnswers')
SyncLog = require('../models/sync-log')
async = require('async')
saveErr = require('../server/errInfo')
Task = require('../models/task')



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
            Task.findOne {url:answer.url}, (err, row) ->
              return saveErr url, 2, {err:err, answer:answer.url} if err

              if row
                console.log "already exits ==>", answer.url

              else
                self.addTask answer.url, (err2, status) ->
                  console.log err2 if err2
                  if status is 3
                    console.log "#{answer.url} do {error}"
                  else if status is 4
                    console.log "#{answer.url} do ok"

          self.getColList(data.paging.next)

        else
          console.log data

      ]




  addTask:(url, cb) ->
    self = @
    async.auto
      addDB:(callback) ->
        task = new Task
        task.url = url
        task.save (err, row) ->
          return cb(err) if err

          callback()

      addDo:['addDB', (callback) ->
        queue.push {url:url, noteStore:self.noteStore}, (err) ->
          if err
            console.log err
            self.changeStatus url, 3, cb

          else
            self.changeStatus url, 4, cb

      ]

  changeStatus: (url, status, cb) ->
    async.auto
      findUrl:(callback) ->
        Task.findOne {url:url}, (err, row) ->
          return cb(err, status) if err

          callback(null, row) if row


      change:['findUrl', (callback, result) ->
        row = result.findUrl
        row.status = status
        row.save (err, row) ->
          return cb(err) if err

          cb(null, status)
      ]







  getColInfo:() ->


module.exports = GetCol
