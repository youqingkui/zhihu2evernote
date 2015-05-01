GetCol = require('../server/getCollection')

url = 'https://api.zhihu.com/collections/21437665/'

g = new GetCol(url)
g.getColList()