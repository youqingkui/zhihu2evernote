GetCol = require('../server/getCollection')
noteStore = require('../server/noteStore')

url = 'https://api.zhihu.com/collections/21437665/answers'

g = new GetCol(noteStore)
g.getColList(url)