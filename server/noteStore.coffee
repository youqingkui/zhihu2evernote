Evernote = require('evernote').Evernote

developerToken = process.env.DeveloperToken
client = new Evernote.Client({
  token:developerToken
})
noteStore = client.getNoteStore('https://app.yinxiang.com/shard/s5/notestore')


module.exports = noteStore