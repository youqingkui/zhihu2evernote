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
nodeUrl = require('url')

reqOp = (url) ->
  options =
    url:url
#    timeout:5000
    headers:
      'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36',
      'Cookie':cookie

  return options




pageImport = (op, cb) ->
  async.auto
    getPage:(c) ->
      request.get op, (err, res, body) ->
        console.log err
        return c(err) if err
        $ = cheerio.load(body)
        answerList = $("#zh-list-answer-wrap > div")
        c(null, answerList, $)

    getContent:['getPage', (c, result) ->
      answerList = result.getPage[0]
      $ = result.getPage[1]

      noteArr = []
      oldTitle = ''
      oldSourceUrl = ''
      async.eachSeries answerList, (item, callback) ->
        tmp = {}
        title = $(item).find("h2.zm-item-title").text()
        if not title
          title = oldTitle
        oldTitle = title
        tmp.title = title
        sourceUrl = $(item).find("h2.zm-item-title a").attr('href')
        if not sourceUrl
          sourceUrl = oldSourceUrl
        else
          sourceUrl = 'http://www.zhihu.com' + sourceUrl
        oldSourceUrl = sourceUrl
        content1 = $(item).find(".content.hidden").text()
#        console.log "content1  ====="
#        console.log content1
#        console.log "content1  ===== \n"

        $2 = cheerio.load(content1, {decodeEntities: false})
        # 移除其他属性
        rmAttr $2

        console.log "$2.html({xmlMode:true}),",$2.html({xmlMode:true})

        if true
          content2 = $2.html({xmlMode:true})
          tmp.content = content2
          tmp.sourceUrl = sourceUrl
          tmp.resourceArr = []
          makeNote noteStore, title, content2, sourceUrl,
          tmp.resourceArr, (err2, note) ->
            return callback(err2) if err2
            console.log "create ok #{note.title}"
            callback()
        else
            changeImg $2, $2("img"), (err, resourceArr) ->
            return callback(err) if err
            content2 = $2.html({xmlMode:true})
            tmp.content = content2
            tmp.sourceUrl = sourceUrl
            tmp.resourceArr = resourceArr
            makeNote noteStore, title, content2, sourceUrl,
            resourceArr, (err2, note) ->
              return callback(err2) if err2
              console.log "create ok #{note.title}"
              callback()

      ,(eachErr) ->
        return cb(eachErr) if eachErr
        c(null, noteArr)
    ]
  ,(eachErr) ->
      console.log eachErr
      return cb(eachErr) if eachErr

      cb()


# 移除不需要属性
rmAttr = ($) ->

  $("a, span, img, i, div, code")
  .map (i, elem) ->
    for k of elem.attribs
      console.log k
      if k != 'src'
        $(this).removeAttr(k)

#  .removeAttr('data-rawwidth').removeAttr('data-rawheight')
#  .removeAttr('data-original').removeAttr('data-hash')
#  .removeAttr('data-editable').removeAttr('data-title')
#  .removeAttr('data-tip').removeAttr("eeimg").removeAttr('alt')
#  .removeAttr('data-swfurl')


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


getPageCount = (url, cb) ->
  request.get url, (err, res, body) ->
    return cb(err) if err

    $ = cheerio.load body
    spanArr = $(".zm-invite-pager span")
    pageCount = $(spanArr[spanArr.length - 2]).text()

    cb(null, Number(pageCount))

op = reqOp('http://www.zhihu.com/collection/29469118')

async.auto
  getPage:(cb) ->
    getPageCount op, (err, count) ->
      return cb(err) if err
      console.log "count", count
      cb(null, count)

  importPage:['getPage', (cb, result) ->
    pageCount = result.getPage
    pageArr = [0].concat([2..pageCount])
    console.log "pageArr ==>", pageArr
    async.eachSeries pageArr, (item, callback) ->
      unless item is 0
        newUrl = op.url + '?page=' + item
        op2 = reqOp(newUrl)

      else
        op2 = op
      console.log "op2 ==>", op2
      pageImport op2, (err, result) ->
        return cb(err) if err

        console.log "#{op2.url} is import ok"

        callback()

    ,(eachErr) ->
      return console.log eachErr if eachErr

      console.log "all page do !!"

  ]






