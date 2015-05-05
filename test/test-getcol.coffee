GetCol = require('../server/getCollection')
noteStore = require('../server/noteStore')
schedule = require("node-schedule")
rule = new schedule.RecurrenceRule()
rule.dayOfWeek = [0, new schedule.Range(1, 6)]
rule.hour = 10
rule.minute = 30

j = schedule.scheduleJob rule, () ->
  url = 'https://api.zhihu.com/collections/29469118/answers'

  g = new GetCol(noteStore)
  g.getColList(url)