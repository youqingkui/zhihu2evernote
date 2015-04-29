queue = require('../server/queue')
noteStore = require('../server/noteStore')
cookie = process.env.ZhiHu
url1 = 'http://www.zhihu.com/question/22896560/answer/44790537'
url2 = 'http://www.zhihu.com/question/23854296/answer/25906136'
url3 = 'http://www.zhihu.com/question/27971326/answer/45822583'

#console.log('worker is processing task: ', url, noteStore, cookie)

queue.push(
  {url:url1, noteStore:noteStore, cookie:cookie},
  (err) ->
    return console.log err if err
)

queue.push(
  {url:url2, noteStore:noteStore, cookie:cookie},
  (err) ->
    return console.log err if err
)


queue.push(
  {url:url3, noteStore:noteStore, cookie:cookie},
  (err) ->
    return console.log err if err
)

