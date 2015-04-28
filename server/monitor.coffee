SyncLog = require('../models/sync-log')
request = require('request')
cheerio = require('cheerio')
async = require('async')
makeNote = require('./createNote')


class Monitor
  constructor: (@colUrl, @noteStore, @cookie) ->
    @$ = null
    @_xsrf = ''



  compleStatus: () ->


  getLogPage: (cb) ->
    self = @

    request.get self.colUrl + '/log', (err, res, body) ->
      return cb(err) if err

      $ = cheerio.load body
      self.$ = $
      cb()

  checkFav: (cb) ->
    self = @
    self._xsrf = self.$("input[name='_xsrf']").val()
    favDivList = self.$("div.zm-item")
    favList = self.$("div.zm-item ins > a")
    


  createNote: (noteStore, title, tags, content, soureUrl, resArr, cb) ->
    makeNote noteStore, title, tags, content, soureUrl, resArr,
      (err, note) ->
        return cb(err) if err

        console.log "note #{note.title} create ok"
        cb()


  # 获取收藏内容
  getFavContenr: (favUrl, cb) ->
    request.get favUrl, (err, res, body) ->
      return cb(err) if err

      $ = cheerio.load(body)

      tagArr = []
      tagList = $("a.zm-item-tag")
      tagList.each (i, elem) ->
        tagName = $(elem).text().trim()
        tagArr.push tagName

      content = $("#zh-question-answer-wrap .zm-editable-content").text()
      timeInfo = $("#zh-question-answer-wrap span.answer-date-link-wrap").text()
      content += timeInfo

      cb(null, content)


  # 转换收藏内容
  changeContent: (content, cb) ->
    $ = cheerio.load(content)
    $("a, span, img, i, div, code")
    .map (i, elem) ->
      for k of elem.attribs
        if k != 'src'
          $(this).removeAttr(k)

    imgs = $("img")
    resourceArr = []
    async.each imgs, (item, callback) ->
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

    ,() ->
      changeContent = $.html({xmlMode:true})
      cb(null, changeContent, resourceArr)



  readImgRes: (imgUrl, cb) ->
    op = reqOp(imgUrl)
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

















