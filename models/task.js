// Generated by CoffeeScript 1.8.0
(function() {
  var TaskSchema, mongoose;

  mongoose = require('./mongoose');

  TaskSchema = mongoose.Schema({
    url: String,
    status: {
      type: Number,
      "default": 1
    }
  });

  module.exports = mongoose.model('Task', TaskSchema);

}).call(this);

//# sourceMappingURL=task.js.map
