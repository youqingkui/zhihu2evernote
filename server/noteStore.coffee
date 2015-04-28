Evernote = require('evernote').Evernote

developerToken = process.env.DeveloperToken
#developerToken = process.env.DeveloperTokenTest
client = new Evernote.Client({
  token:developerToken
})
noteStore = client.getNoteStore('https://app.yinxiang.com/shard/s5/notestore')
#noteStore = client.getNoteStore('https://sandbox.evernote.com/shard/s1/notestore')



module.exports = noteStore