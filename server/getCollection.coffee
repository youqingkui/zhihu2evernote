requrest = require('request')
fs = require('fs')
path = require('path')
certFile = path.resolve(__dirname, 'zhihu.crt')
keyFile = path.resolve(__dirname, 'zhihu.key')

class GetCol
  constructor:(@url) ->
    @headers = {
      'User-Agent':'osee2unifiedRelease/332 CFNetwork/711.3.18 Darwin/14.0.0'
      'Authorization':'oauth 5774b305d2ae4469a2c9258956ea49'
      'Accept-Encoding':'gzip, deflate, sdch'
      'Accept-Language':'zh-CN,zh;q=0.8,en;q=0.6'
      'Accept':'*'
      'Content-Type':'application/json'
    }



  getColList:() ->
    self = @
    url = self.url + 'answers'
    op = {
      url:url
      headers:self.headers
    }
    requrest.get op, (err, res, body) ->
      return console.log err if err
#      data = JSON.parse(body)
      console.log(new Buffer(body).toString('utf-8'))




  getColInfo:() ->


module.exports = GetCol
