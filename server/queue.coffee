async = require('async')
makeNote = require('./createNote')
request = require('request')
cheerio = require('cheerio')
Evernote = require('evernote').Evernote
crypto = require('crypto')
#SyncLog = require('../models/sync-log')






q = async.queue (data, cb) ->
  console.log('worker is processing task: ', data.url)
  task = new Save2Evernote(data.url, data.noteStore, data.cookie)
  async.series [
    (callback) ->
      task.getUrlPage (err) ->
        return callback(err) if err

        callback()

    (callback) ->
      task.checkFav () ->
        callback()

    (callback) ->
      task.changeContent (err) ->
        return callback (err) if err

        callback()

    (callback) ->
      task.createNote (err) ->
        return cb(err) if err

        callback()

#    (callback) ->
#      task.saveLog (err) ->
#        return cb(err) if err
#        callback()

  ],(err) ->
    return cb(err) if err
    console.log("worker is end task: ", data.url)
    cb()
, 15


q.saturated = () ->
  console.log('all workers to be used')


q.empty = () ->
  console.log('no more tasks wating')


q.drain = () ->
  console.log('all tasks have been processed')


class Save2Evernote
  constructor: (@url, @noteStore, @cookie) ->
    @$ = null
    @title = ''
    @tagArr = []
    @content = ''
    @enContent = ''
    @resourceArr = []


  # 获取页面内容
  getUrlPage: (cb) ->
    self = @
    op = self.reqOp(self.url)
    request.get op, (err, res, body) ->
      return cb(err) if err

      $ = cheerio.load body, {decodeEntities: false}
      self.$ = $
      cb()

  # 得到页面信息
  checkFav: (cb) ->
    self = @
    $ = self.$

    tagList = $("a.zm-item-tag")
    tagList.each (i, elem) ->
      tagName = $(elem).text().trim()
      self.tagArr.push tagName

    self.title = $("#zh-question-title .zm-item-title a").text()

    self.content = $(".zm-item-answer .zm-editable-content").html()
    self.timeInfo = $("#zh-question-answer-wrap span.answer-date-link-wrap").text()
    self.content += self.timeInfo
    cb()

  # 转换内容
  changeContent: (cb) ->
    self = @
    $ = cheerio.load(self.content, {decodeEntities: false})
    $("noscript").remove()
    $("a, span, img, i, div, code")
    .map (i, elem) ->
      for k of elem.attribs
        if k != 'data-actualsrc'
          $(this).removeAttr(k)

    imgs = $("img")
    console.log imgs.length
    async.each imgs, (item, callback) ->
      src = $(item).attr('data-actualsrc')
      console.log "src ==>",src
      self.readImgRes src, (err, resource) ->
        return cb(err) if err

        self.resourceArr.push resource
        md5 = crypto.createHash('md5')
        md5.update(resource.image)
        hexHash = md5.digest('hex')
        newTag = "<en-media type=#{resource.mime} hash=#{hexHash} />"
        console.log newTag
        $(item).replaceWith(newTag)

        callback()

    ,() ->
      self.enContent = $.html({xmlMode:true, decodeEntities: false})

      cb()

  # 创建笔记
  createNote: (cb) ->
    makeNote @noteStore, @title, @tagArr, @enContent, @url, @resourceArr,
      (err, note) ->
        return cb(err) if err

        console.log "+++++++++++++++++++++++"
        console.log "#{note.title} create ok"
        console.log "+++++++++++++++++++++++"

        cb()

#  # 保存记录
#  saveLog: (cb) ->
#    logs = new SyncLog()
#    logs.title = @title
#    logs.content = @content
#    logs.created = Date.parse(new Date())
#    logs.updated = logs.created
#    logs.tagNames = @tagArr
#    logs.href = @url
#    logs.save (err, row) ->
#      return cb(err) if err
#
#      cb()


  # 读取远程图片
  readImgRes: (imgUrl, cb) ->
    self = @
    op = self.reqOp(imgUrl)
    op.encoding = 'binary'
    async.auto
      readImg:(callback) ->
        request.get op, (err, res, body) ->
          return cb(err) if err
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

  reqOp:(getUrl) ->
    self =  @
    options =
      url:getUrl
      headers:
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36',
        'Cookie':self.cookie

    return options




module.exports = q