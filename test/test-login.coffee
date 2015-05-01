Login = require('../server/clientLogin')

params = {
  url:'https://api.zhihu.com/client_login'
  client_id:'5774b305d2ae4469a2c9258956ea49'
  grant_type:'password'
  password:''
  source:'com.zhihu.ios'
  username:''
  signature:'e00d1cd9e1cacaddee4b08b45b303c75dcf9ad38'
#  timestamp:Date.parse(new Date()) / 1000
  timestamp:'1430465497'
}

login = new Login(params)
login.login()
