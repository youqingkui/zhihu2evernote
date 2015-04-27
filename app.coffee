request = require('request')
async = require('async')
cookie = process.env.ZhiHu
cheerio = require('cheerio')
makeNote = require('./server/createNote')
noteStore = require('./server/noteStore')
Evernote = require('evernote').Evernote
fs = require('fs')
crypto = require('crypto')
mime = require('mime')

reqOp = (url) ->
  options =
    url:url
    headers:
      'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36',
      'Cookie':cookie

  return options


#request.get op, (err, res, body) ->
#  return console.log err if err
#
#  $ = cheerio.load(body, {})
#
#  answerList = $("#zh-list-answer-wrap > div")
#  oldTitle = ''
#  async.eachSeries answerList, (item, callback) ->
#
#    title = $(item).find("h2.zm-item-title").text()
#    if not title
#      title = oldTitle
#    oldTitle = title
#    content1 = $(item).find(".content.hidden").text()
#    console.log "content1  ====="
#    console.log content1
#    console.log "content1  ===== \n"
#    $2 = cheerio.load(content1, {decodeEntities: false})
#    # 移除其他属性
#    $2("a, span, img, i, div, code")
#    .removeAttr("class").removeAttr("href")
#    .removeAttr('data-rawwidth').removeAttr('data-rawheight')
#    .removeAttr('data-original').removeAttr('data-hash')
#    .removeAttr('data-editable').removeAttr('data-title')
#    .removeAttr('data-tip').removeAttr("eeimg").removeAttr('alt')
#
#    # 改变IMG
#    changeImg $2, $2("img"), (err, resourceArr) ->
#
#      content2 = $2.html({xmlMode:true})
#      console.log "content2 ======"
#      console.log content2
#      console.log "content2 ======"
#      makeNote noteStore, title, content2,'http://www.zhihu.com/collection/29469118', resourceArr, (err1, note) ->
#        return console.log err1 if err1
#        return console.log note
#
#
##      callback()
#
#  ,(eachErr) ->
#    return console.log eachErr if eachErr




pageImport = (op, cb) ->
  async.auto
    getPage:(c) ->
      request.get op, (err, res, body) ->
        return c(err) if err
        $ = cheerio.load(body)
        answerList = $("#zh-list-answer-wrap > div")
        c(null, answerList, $)

    getContent:['getPage', (c, result) ->
      answerList = result.getPage[0]
      $ = result.getPage[1]

      noteArr = []
      oldTitle = ''
      async.eachSeries answerList, (item, callback) ->
        tmp = {}
        title = $(item).find("h2.zm-item-title").text()
        if not title
          title = oldTitle
        oldTitle = title
        tmp.title = title
        sourceUrl = 'http://www.zhihu.com/' + $(item).find("h2.zm-item-title a").attr('href')
        content1 = $(item).find(".content.hidden").text()
        console.log "content1  ====="
        console.log content1
        console.log "content1  ===== \n"

        $2 = cheerio.load(content1, {decodeEntities: false})
        # 移除其他属性
        rmAttr $2

        changeImg $2, $2("img"), (err, resourceArr) ->
          return callback(err) if err
          content2 = $2.html({xmlMode:true})
          tmp.content = content2
          tmp.sourceUrl = sourceUrl
          tmp.resourceArr = resourceArr
          noteArr.push tmp
          callback()

      ,(eachErr) ->
        return cb(eachErr) if eachErr
        c(null, noteArr)
    ]

    createNote:['getContent', (c, result) ->
      noteArr = result.getContent
      async.eachSeries noteArr, (item, callback) ->
#        console.log item
        makeNote noteStore, item.title, item.content, item.sourceUrl,
        item.resourceArr, (err, note) ->
          return c(err) if err
          console.log note

          callback()

      ,(eachErr) ->
        return cb(eachErr) if eachErr
        cb()
    ]


# 移除不需要属性
rmAttr = ($) ->

  $("a, span, img, i, div, code")
  .removeAttr("class").removeAttr("href")
  .removeAttr('data-rawwidth').removeAttr('data-rawheight')
  .removeAttr('data-original').removeAttr('data-hash')
  .removeAttr('data-editable').removeAttr('data-title')
  .removeAttr('data-tip').removeAttr("eeimg").removeAttr('alt')


# 替换img为en-media
changeImg = ($, $imgs, cb) ->
  resourceArr = []
  async.eachSeries $imgs, (item, callback) ->
    src = $(item).attr('src')

    eg = async.compose(encodeImg, getImgRes)
    eg src, (err, resource) ->
      return console.log err if err
      resourceArr.push resource

      md5 = crypto.createHash('md5')
      md5.update(resource.image)
      hexHash = md5.digest('hex')
      newTag = "<en-media type=#{resource.mime} hash=#{hexHash} />"
      console.log newTag
      $(item).replaceWith(newTag)

      callback()

  ,(eachErr) ->
    return console.log eachErr if eachErr
    cb(null, resourceArr)


# 获取远程图片
getImgRes = (imgUrl, cb) ->
  sUrl = imgUrl.split('/')
  imgFile = sUrl[sUrl.length - 1]
  img = fs.createWriteStream imgFile
  request
    .get imgUrl
    .on 'response', (res) ->
      console.log res.statusCode
    .on 'error', (err) ->
      console.log err
    .on 'end', () ->
      console.log "#{imgUrl} down ok"
      cb(null, imgFile)

  .pipe(img)

# 按evernote编码图片
encodeImg = (img, cb) ->
  image = fs.readFileSync img
  hash = image.toString('base64')

  data = new Evernote.Data()
  data.size = image.length
  data.bodyHash = hash
  data.body = image

  resource = new Evernote.Resource()
  resource.mime = mime.lookup(img)
  resource.data = data
  resource.image = image

  cb(null, resource)



op = reqOp('http://www.zhihu.com/collection/29469118')
pageImport op, (err, result) ->
  return console.log err if err

  console.log "hello ok?"





