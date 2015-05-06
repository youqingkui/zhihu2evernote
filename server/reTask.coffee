Task = require('../models/task')
queue = require('../server/getAnswers')
async = require('async')


class ReTask
  constructor: () ->


  resume:() ->
    async.auto
      findTask:(callback) ->
        Task.find {$or:[{status:0}, [{status:1}]]}, (err, rows) ->
          return console.log err if err

          callback(null, rows)

      addTask:['findTask', (callback, result) ->
        taskArr = result.findTask
        taskArr.forEach (task) ->
          queue.push {url:task.url, noteStore:self.noteStore}, (err) ->
            Task.findOne {url:task.url}, (err2, row) ->
              return console.log err2 if err2


              if err
                console.log err

              else
                self.changeStatus task.url, 4, cb

      ]