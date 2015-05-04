request = require('request')
cheerio = require('cheerio')
async = require('async')
makeNote = require('./createNote')
Evernote = require('evernote').Evernote
crypto = require('crypto')


q = async.queue (data, cb) ->
  console.log "#{data.url} add queue"
  g = new GetAnswer(data.url, data.noteStore)
  async.series [
    (callback) ->
      g.getContent(callback)

    (callback) ->
      g.changeContent(callback)

    (callback) ->
      g.createNote(callback)

  ],() ->
    cb()
, 2


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


  getContent:(cb) ->
    self = @
    op = {
      url:self.url
      headers:self.headers
    }

    request.get op, (err, res, body) ->
      return console.log err if err

      data = JSON.parse(body)
      self.title = data.question.title
      self.tagArr = []
      self.sourceUrl = 'http://www.zhihu.com/question/'+
                data.question.id + '/answer/' + data.id

      self.content = data.content

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
    async.each imgs, (item, callback) ->
      src = $(item).attr('data-actualsrc')
      if not src
#        console.log item
        src = $(item).attr('src')
      console.log "src ==>",src
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
      self.enContent = $.html({xmlMode:true, decodeEntities: false})

      cb()

  # 创建笔记
  createNote: (cb) ->
    self = @
    makeNote @noteStore, @title, @tagArr, @enContent, @sourceUrl, @resourceArr,
      (err, note) ->
        console.log "@@@ #{self.title} @@@@@"
        return saveErr(self.url, 6, {err:err, title:self.title}, cb) if err

        console.log "+++++++++++++++++++++++"
        console.log "#{note.title} create ok"
        console.log "+++++++++++++++++++++++"

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

