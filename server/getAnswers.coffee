request = require('request')
cheerio = require('cheerio')
async = require('async')
makeNote = require('./createNote')
Evernote = require('evernote').Evernote
crypto = require('crypto')
SyncLog = require('../models/sync-log')
saveErr = require('../server/errInfo')
Task = require('../models/task')


q = async.queue (data, cb) ->
  console.log "#{data.url} now do"
  g = new GetAnswer(data.url, data.noteStore)
  async.series [
    (callback) ->
      g.changeStatus(callback)

    (callback) ->
      g.getContent(callback)

    (callback) ->
      g.changeContent(callback)

    (callback) ->
      g.createNote(callback)

#    (callback) ->
#      g.saveLog(callback)

  ],(err) ->
    return cb(err) if err
    cb()
, 10


q.saturated = () ->
  console.log('all workers to be used')


q.empty = () ->
  console.log('no more tasks wating')


q.drain = () ->
  console.log('all tasks have been processed')






class GetAnswer
  constructor:(@url, @noteStore) ->
    @headers = {
      'User-Agent':'osee2unifiedRelease/332 CFNetwork/711.3.18 Darwin/14.0.0'
      'Authorization':'oauth 5774b305d2ae4469a2c9258956ea49'
      'Content-Type':'application/json'
    }
    @resourceArr = []

  changeStatus:(cb) ->
    self = @
    Task.findOne {url:self.url, status:1}, (err, row) ->
      return cb(err) if err

      if row
        row.status = 2
        row.save (err2, row2) ->
          return cb(err2) if err2
          cb()

      else
        console.log "changeStatus not find url:#{self.url}"
        cb()


  getContent:(cb) ->
    self = @
    op = {
      url:self.url
      headers:self.headers
      gzip:true
    }

    request.get op, (err, res, body) ->
      return saveErr(op.url, 3, {err:err, fun:'getContent'},cb) if err
      data = JSON.parse(body)
      self.title = data.question.title
      self.tagArr = []
      self.sourceUrl = 'http://www.zhihu.com/question/'+
                data.question.id + '/answer/' + data.id

      self.content = data.content
      self.created = data.created_time
      self.updated = data.updated_time

      cb()

  # 转换内容
  changeContent: (cb) ->
    self = @
    $ = cheerio.load(self.content, {decodeEntities: false})
    $("a, span, img, i, div, code")
    .map (i, elem) ->
      for k of elem.attribs
        if k != 'data-actualsrc' and k != 'src'
          $(this).removeAttr(k)

    imgs = $("img")
    console.log "#{self.title} find img length => #{imgs.length}"
    async.eachSeries imgs, (item, callback) ->
      src = $(item).attr('data-actualsrc')
      if not src
        src = $(item).attr('src')

      self.readImgRes src, (err, resource) ->
        return saveErr(src, 5, {err:err, title:self.title, url:self.url}, cb) if err

        self.resourceArr.push resource
        md5 = crypto.createHash('md5')
        md5.update(resource.image)
        hexHash = md5.digest('hex')
        newTag = "<en-media type=#{resource.mime} hash=#{hexHash} />"
        $(item).replaceWith(newTag)

        callback()

    ,() ->
      console.log "#{self.title} #{imgs.length} imgs down ok"
      self.enContent = $.html({xmlMode:true, decodeEntities: false})

      cb()

  # 创建笔记
  createNote: (cb) ->
    self = @
    makeNote @noteStore, @title, @tagArr, @enContent, @sourceUrl, @resourceArr,
      @created, @updated
      (err, note) ->
        if err
          return saveErr(self.url, 6, {err:err, title:self.title}, cb) if err

        console.log "+++++++++++++++++++++++"
        console.log "#{note.title} create ok"
        console.log "+++++++++++++++++++++++"

        cb()

  # 保存记录
  saveLog: (cb) ->
    logs = new SyncLog()
    logs.title = @title
    logs.created = @created
    logs.updated = @updated
    logs.tagNames = @tagArr
    logs.href = @url
    logs.save (err, row) ->
      return cb(err) if err

      cb()


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
          mimeType = mimeType.split(';')[0]
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
    options =
      url:getUrl
      headers:
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36',

    return options


module.exports = q

