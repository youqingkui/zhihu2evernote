// Generated by CoffeeScript 1.8.0
(function() {
  var GetCol, g, noteStore, url;

  GetCol = require('../server/getCollection');

  noteStore = require('../server/noteStore');

  url = 'https://api.zhihu.com/collections/21437665/answers';

  g = new GetCol(noteStore);

  g.getColList(url);

}).call(this);

//# sourceMappingURL=test-getcol.js.map
