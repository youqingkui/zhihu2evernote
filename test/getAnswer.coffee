GetAnswer = require('../server/getAnswers')


url = 'https://api.zhihu.com/answers/27770694'

g = new GetAnswer(url)
g.getContent()