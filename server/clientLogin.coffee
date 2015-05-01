requrest = require('request')

#

class ClientLogin
  constructor: (@params) ->


  login:() ->
    self = @

    op = {
      url: self.params.url
      headers:{
        'User-Agent':'osee2unifiedRelease/332 (iPad; iOS 8.3; Scale/2.00)'
#        'Authorization':'Basic NTc3NGIzMDVkMmFlNDQ2OWEyYzkyNTg5NTZlYTQ5OjNjOTIyMTBhMzIxMjQ2N2U5NDc0ZTAwNmI2MjZhYQ=='
#        'Cookie':'__utma=155987696.923313156.1420173563.1420173563.1420173563.1; __utmz=155987696.1420173563.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); _ga=GA1.2.923313156.1420173563; q_c1=18669034a3f1471bae4821c346139b16|1430465390000|1419666287000'
      }
      form:self.params
    }

    requrest.post op, (err, res, body) ->
      return console.log err if err

      console.log body


module.exports = ClientLogin
