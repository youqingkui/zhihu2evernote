request = require('request')


class GetAnswer
  constructor:(@url) ->
    @headers = {
      'User-Agent':'osee2unifiedRelease/332 CFNetwork/711.3.18 Darwin/14.0.0'
      'Authorization':'oauth 5774b305d2ae4469a2c9258956ea49'
      'Content-Type':'application/json'
    }


  getContent:() ->
    self = @
    op = {
      url:self.url
      headers:self.headers
    }

    request.get op, (err, res, body) ->
      return console.log err if err

      data = JSON.parse(body)
      console.log data


module.exports = GetAnswer

