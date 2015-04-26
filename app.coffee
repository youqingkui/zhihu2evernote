request = require('request')
async = require('async')
cookie = process.env.ZhiHu
cheerio = require('cheerio')
makeNote = require('./server/createNote')
noteStore = require('./server/noteStore')
Evernote = require('evernote').Evernote

reqOp = (url) ->
  options =
    url:url
    headers:
      'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36',
      'Cookie':cookie

  return options


op = reqOp('http://www.zhihu.com/collection/29469118')
request.get op, (err, res, body) ->
  return console.log err if err

  $ = cheerio.load(body)

  answerList = $("#zh-list-answer-wrap > div")

  $ = cheerio.load(answerList[0])
  title = $("h2.zm-item-title").text()
  content1 = $(".content.hidden").text().replace(/<br>/g, '</br>')
  console.log content1
  $2 = cheerio.load(content1)
  $2("a, span").removeAttr("class").removeAttr("href")
  content2 = $2.html()
  console.log content2
  content3 = "<img src='http://pic3.zhimg.com/31fa9c0fdbe89aa0464c1110cc3c0382_r.jpg'/>"
  makeNote noteStore, title, content3,'http://www.zhihu.com/collection/29469118', (err1, note) ->
    return console.log err1 if err1
    console.log note
