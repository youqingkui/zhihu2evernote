express = require('express')
path = require('path')
fs = require('fs')
favicon = require('serve-favicon')
logger = require('morgan')
cookieParser = require('cookie-parser')
session = require('express-session')
bodyParser = require('body-parser')
routes = require('./routes/index')
col = require('./routes/collection')
user = require('./routes/users')
app = express()

accessLog = fs.createWriteStream 'access.log',
  flags: 'a'

errorLog  = fs.createWriteStream 'error.log',
  flags: 'a'

# view engine setup
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'jade'


# uncomment after placing your favicon in /public
app.use(favicon(__dirname + '/public/images/favicon.ico'));
app.use logger('dev')
app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: false)
app.use cookieParser()
app.use(session({
  secret: 'keyboard cat',
  resave: false,
  saveUninitialized: true
}))
app.use express.static(path.join(__dirname, 'public'))

app.use logger 'combined', {stream: accessLog}
app.use '/', routes
app.use '/users', user

app.use '/collection', (req, res, next) ->
  if not req.session.username
    return res.send "need login"
  else next()
,col

# catch 404 and forward to error handler
app.use (req, res, next) ->
  err = new Error('Not Found')
  err.status = 404
  next err
  return

# error handlers
app.use (err, req, res, next) ->
  meta = '[' + new Date() + '] ' + req.url + '\n'
  errorLog.write(meta + err.stack + '\n');
  next(err)



# development error handler
# will print stacktrace
if app.get('env') == 'development'
  app.use (err, req, res, next) ->
    res.status err.status or 500
    res.render 'error',
      message: err.message
      error: err
    return

# production error handler
# no stacktraces leaked to user
app.use (err, req, res, next) ->
  res.status err.status or 500
  res.render 'error',
    message: err.message
    error: {}
  return
module.exports = app