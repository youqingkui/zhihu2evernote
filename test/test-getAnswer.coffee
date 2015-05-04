queue = require('../server/getAnswers')
noteStore = require('../server/noteStore')
async = require('async')

data1 = {
  url:'https://api.zhihu.com/answers/44378067'
  noteStore:noteStore
}

data2 = {
  url:'https://api.zhihu.com/answers/20149124'
  noteStore:noteStore
}

data3 = {
  url:'https://api.zhihu.com/answers/16406064'
  noteStore:noteStore
}


queue.push data1, () ->
  console.log "data1 do ok"


queue.push data2, () ->
  console.log "data2 do ok"


queue.push data3, () ->
  console.log "data3 do ok"