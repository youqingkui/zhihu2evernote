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

  $1 = cheerio.load(answerList[1])
  title = $1("h2.zm-item-title").text()
  content1 = $1(".content.hidden").text().replace(/<br>/g, '<br/>')
  console.log "content1  ====="
  console.log content1
  console.log "content1  ===== \n"
  $2 = cheerio.load(content1, {decodeEntities: false})
  # 移除其他属性
  $2("a, span, img, i").removeAttr("class").removeAttr("href")
  .removeAttr('data-rawwidth').removeAttr('data-rawheight')
  .removeAttr('data-original').removeAttr('data-hash')
  .removeAttr('data-editable').removeAttr('data-title')
  .removeAttr('data-tip')

#  imgs = $2("img")
#  imgs.each (idx, element) ->
#    src = $2(element).attr('src')
#    height = $2(element).attr('height')
#    width = $2(element).attr('width')
#    newTag = $("<img src=#{src} width=#{width} height=#{height} />")
#    $2(element).replaceWith(newTag)


  content2 = $2.html({xmlMode:true})
  console.log "content2 ======"
  console.log content2
  console.log "content2 ======"
  makeNote noteStore, title, content2,'http://www.zhihu.com/collection/29469118', (err1, note) ->
    return console.log err1 if err1
    console.log note
