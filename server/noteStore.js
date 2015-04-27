// Generated by CoffeeScript 1.8.0
(function() {
  var Evernote, client, developerToken, noteStore;

  Evernote = require('evernote').Evernote;

  developerToken = process.env.DeveloperToken;

  client = new Evernote.Client({
    token: developerToken
  });

  noteStore = client.getNoteStore('https://sandbox.evernote.com/shard/s1/notestore');

  module.exports = noteStore;

}).call(this);

//# sourceMappingURL=noteStore.js.map
