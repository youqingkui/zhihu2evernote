queue = require('../server/queue')
noteStore = require('../server/noteStore')
cookie = process.env.ZhiHu
url = 'http://www.zhihu.com/question/29852397/answer/46153324'

#console.log('worker is processing task: ', url, noteStore, cookie)

queue.push({url, noteStore, cookie,(err) ->return console.log err if err})

