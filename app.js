var express = require('express');
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var admin = require("firebase-admin");
var index = require('./routes/index');
var moment = require('moment-timezone');

var dashboard = require('./routes/dashboard');
var yaml_config = require('node-yaml-config');

var config = yaml_config.load(__dirname + '/config/config.yaml');
var app = express();
var server = require('http').Server(app);
var io = require('socket.io')(server);

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'pug');

//setup Socket.io
app.use(function(req, res, next){
  res.io = io;
  next();
});

// uncomment after placing your favicon in /public
//app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));


//routes
app.use('/', index);
app.use('/dashboard', dashboard);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  var err = new Error('Not Found');
  err.status = 404;
  next(err);
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

// firebase

var serviceAccount = require(__dirname +"/config/" + config.firebase.serviceaccount_json);
console.log(config.firebase.domain)

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://"+config.firebase.domain+".firebaseio.com"
});

var ref = admin.database().ref("logger")
ref.orderByChild('timestamp').limitToLast(1).on("value", function(snapshot) {
    console.log(snapshot.val())
    io.emit("log", snapshot.val())
});


module.exports = {app: app, server: server};
