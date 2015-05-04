requrest = require('request')
fs = require('fs')
path = require('path')
queue = require('../server/getAnswers')

class GetCol
  constructor:(@noteStore) ->
    @headers = {
      'User-Agent':'osee2unifiedRelease/332 CFNetwork/711.3.18 Darwin/14.0.0'
      'Authorization':'oauth 5774b305d2ae4469a2c9258956ea49'
      'Content-Type':'application/json'
    }



  getColList:(url) ->
    self = @
    op = {
      url:url
      headers:self.headers
      gzip:true
    }
    requrest.get op, (err, res, body) ->
      return console.log err if err
      data = JSON.parse(body)
#      console.log data
      if data.data.length
        for i in data.data
          console.log "#{i.url} add queue, queue ==> #{queue.length()}"
          queue.push {url:i.url, noteStore:self.noteStore}, () ->
            console.log "do ok ==>", i.url
        self.getColList(data.paging.next)

      else
        console.log data


  getColInfo:() ->


module.exports = GetCol
