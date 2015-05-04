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
      'Content-Type':'application/json'
    }



  getColList:() ->
    self = @
    url = self.url + 'answers'
    op = {
      url:url
      headers:self.headers
      gzip:true
    }
    requrest.get op, (err, res, body) ->
      return console.log err if err
      data = JSON.parse(body)
      console.log data.data[0]


  getColInfo:() ->


module.exports = GetCol
