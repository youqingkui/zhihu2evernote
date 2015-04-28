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
querystring = require('querystring')

reqOp = (url) ->
  options =
    url:url
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
#      oldSourceUrl = ''
      async.eachSeries answerList, (item, callback) ->
        title = $(item).find("h2.zm-item-title").text()
        if not title
          title = oldTitle
        oldTitle = title
#        sourceUrl = $(item).find("h2.zm-item-title a").attr('href')
#        if not sourceUrl
#          sourceUrl = oldSourceUrl
#        else
#          sourceUrl = 'http://www.zhihu.com' + sourceUrl
#        oldSourceUrl = sourceUrl
        content1 = $(item).find(".content.hidden").text()
        tagUrl = $(item).find("a.toggle-expand").attr('href')
        tagUrl = 'http://www.zhihu.com' + tagUrl

        $2 = cheerio.load(content1, {decodeEntities: false})
        # 移除其他属性
        rmAttr $2
        console.log "$2.html({xmlMode:true}),",$2.html({xmlMode:true})

        composeCreateNote $2, title, tagUrl, tagUrl, noteStore, (err, note) ->
          return callback(err) if err

          callback()


      ,(eachErr) ->
        return cb(eachErr) if eachErr
        c(null, noteArr)
    ]
  ,(eachErr) ->
      console.log eachErr
      return cb(eachErr) if eachErr

      cb()

composeCreateNote = ($, title, tagUrl, sourceUrl, noteStore, cb) ->
  async.parallel [
    (callback) ->
      getTag tagUrl, (tagList) ->
        callback(null, tagList)

    (callback) ->
      changeImgs $, $("img"), (err, resourceArr) ->
        return callback(err) if err
        content = $.html({xmlMode:true})
        callback(null, content, resourceArr)

  ],(endErr, result) ->
    return cb(endErr) if endErr
    console.log "++++++++++++++++++++++++"
    console.log result
    console.log "++++++++++++++++++++++++"
    tagList = result[0]
    content = result[1][0]
    resourceArr = result[1][1]

    makeNote noteStore, title, tagList, content, sourceUrl, resourceArr, (err, note) ->
      return cb(err) if err
      console.log "create ok #{note.title}"
      cb()


# 获取标签
getTag = (url, cb) ->
  op = reqOp(url)
  console.log "tag url ==>", op
  request.get op, (err, res, body) ->
    if err
      console.log err
      return cb(null, [])

    $ = cheerio.load(body)
    tagArr = $("a.zm-item-tag")
    tagList = []
    tagArr.each (i, elem) ->
      tagName = $(elem).text().trim()
      tagList.push tagName
    console.log "tagListtagListtagListtagListtagList ====>",tagList
    cb(tagList)




# 移除不需要属性
rmAttr = ($) ->

  $("a, span, img, i, div, code")
  .map (i, elem) ->
    for k of elem.attribs
      if k != 'src'
        $(this).removeAttr(k)



# 替换img为en-media
changeImgs = ($, $imgs, cb) ->
  resourceArr = []
  async.eachSeries $imgs, (item, callback) ->
    src = $(item).attr('src')

    readImgRes src, (err, resource) ->
      return cb(err) if err

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


# 读取编码远程图片
readImgRes = (imgUrl, cb) ->
  op = reqOp(imgUrl)
  op.encoding = 'binary'
  async.auto
    readImg:(callback) ->
      request.get op, (err, res, body) ->
        return cb(err) if err
#        return fs.writeFileSync('test.jpg', body, 'binary')
        mimeType = res.headers['content-type']
        callback(null, body, mimeType)

    enImg:['readImg', (callback, result) ->
      mimeType = result.readImg[1]
      image = new Buffer(result.readImg[0], 'binary')
      hash = image.toString('base64')

      data = new Evernote.Data()
      data.size = image.length
      data.bodyHash = hash
      data.body = image

      resource = new Evernote.Resource()
      resource.mime = mimeType
      resource.data = data
      resource.image = image
      cb(null, resource)
    ]


getPageCount = (url, cb) ->
  request.get url, (err, res, body) ->
    return cb(err) if err

    $ = cheerio.load body
    spanArr = $(".zm-invite-pager span")
    pageCount = $(spanArr[spanArr.length - 2]).text()

    cb(null, Number(pageCount))

#op = reqOp('http://www.zhihu.com/collection/29469118')
op = reqOp('http://www.zhihu.com/collection/19932288')

async.auto
  getPage:(cb) ->
    getPageCount op, (err, count) ->
      return cb(err) if err
      console.log "count", count
      cb(null, count)

  importPage:['getPage', (cb, result) ->
    pageCount = result.getPage
    parseUrl = nodeUrl.parse(op.url)
    query = querystring.parse(parseUrl.query)
    stratPage = Number(query.page)
    if stratPage
      pageArr = [stratPage..pageCount]
    else
      pageArr = [0].concat([2..pageCount])

    console.log "pageArr ==>", pageArr
    async.eachSeries pageArr, (item, callback) ->
      unless item is 0
        newUrl = parseUrl.protocol + '//' + parseUrl.hostname + parseUrl.pathname + '?page=' + item
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






