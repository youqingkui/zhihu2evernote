GetAnswer = require('../server/getAnswers')
noteStore = require('../server/noteStore')
async = require('async')

url = 'https://api.zhihu.com/answers/44378067'

g = new GetAnswer(url, noteStore)

async.series [
  (callback) ->
    g.getContent(callback)

  (callback) ->
    g.changeContent(callback)

  (callback) ->
    g.createNote(callback)

]