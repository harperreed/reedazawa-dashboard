var express = require('express');
var router = express.Router();
var Wunderground = require('wundergroundnode');
var yaml_config = require('node-yaml-config');
var moment = require('moment-timezone');
var admin = require("firebase-admin");
var request = require('request');

const google = require('googleapis');
const OAuth2 = google.auth.OAuth2;





var config = yaml_config.load(__dirname + '/../config/config.yaml');

const cache = require('node-file-cache').create({"life":1800});

var wunderground = new Wunderground(config.weatherunderground.apikey);

var serviceAccount = require(__dirname +"/../config/" + config.firebase.serviceaccount_json);

var quotations = require(__dirname +"/../config/quotations.json");


const oauth2Client = new OAuth2(
  config.calendar.consumer_key,
  config.calendar.consumer_secret,
  config.calendar.callback
);


/* ------------------- */



function getEvents(auth){
  return new Promise(function(resolve,reject) {
    const calendar = google.calendar('v3');
    console.log("in request")
    console.log(auth)
    params = {
      auth: auth,
      calendarId: 'primary',
      timeMin: (new Date()).toISOString(),
      maxResults: 5,
      singleEvents: true,
      orderBy: 'startTime'
    }

    calendar.events.list(params, function(err, response) {

      if (err) {
        console.log('The API returned an error: ' + err);
        return;
      }
      var events = response.items;
      var events_obj = []


      if (events.length == 0) {
        console.log('No upcoming events found.');
      } else {
        
        for (var i = 0; i < events.length; i++) {
          var event = events[i];
          

          delete event.kind
          delete event.etag
          delete event.id
          delete event.iCalUID
          delete event.recurringEventId
          events_obj.push(event)
        }
        resolve(events_obj);
      }
    });
  });
}

function formatEvents(events_object, callback){
  events_obj = {}
  for (var i = 0; i < events_object.length; i++) {
    var event = events_object[i];
    var start = moment(event.start.dateTime || event.start.date)
    break_form = "dddd [the] Do"
    key = start.format(break_form)
    if (events_obj[key]== undefined){
      events_obj[key] = []
    }
    events_obj[key].push(event)
  }
  callback(events_obj)

}

function grabCalendar(person){
  return new Promise(function(resolve,reject) {
    var key = "events - " + person
    var events = cache.get(key)
    if (events == null){
      console.log(person + " events not cache hit")
      person_oauth_tokens = config.calendar.people[person]

      var auth = new Object()
      auth = oauth2Client

      auth.setCredentials({
          access_token: person_oauth_tokens.access_token,
          refresh_token: person_oauth_tokens.refresh_token
      });

      getEvents(auth).then(function(e) {


        formatEvents(e, function(fe){
          //cache.set(key, fe);
          resolve(fe);
        });

      });
    }else{
      console.log('%s - %s', key, events);
      console.log(person + " events cache hit")
      resolve(events);
    }
  });
}

function getweather() {
    return new Promise(function(resolve,reject) {
        var key = "weather"+ config.weatherunderground.query
        var weather = cache.get(key)
        if (weather == null){

            console.log("Weather cache not hit")
            wunderground.conditions().request(config.weatherunderground.query, function(err, response){
                weather = response
                cache.set(key, weather);
                resolve(weather);
            });

        }else{
            console.log("Weather cache hit")
            resolve(weather);
        }
    });
}


function getLogs() {
    return new Promise(function(resolve,reject) {
        var ref = admin.database().ref("logger")
        ref.orderByChild('timestamp').limitToLast(1).once("value", function(snapshot) {
            resolve(snapshot.val());
        });
    });
}

function getPresence() {
    return new Promise(function(resolve,reject) {

        request.post({
            headers: {'content-type' : 'application/x-www-form-urlencoded'},
            url:     config.presence.url,
            body:    "api_key=" + config.presence.apikey
        }, function(error, response, body){
            
            presence = JSON.parse(body)

            resolve(presence)
        });

    });
}


/* GET home page. */
router.get('/', function(req, res, next) {
    variables = {
            title: config.title,
    }
    res.render('dashboard-async', variables);
});


router.get('/update', function(req, res, next) {
    /* Handle weather */

    /* Handle quotation */
    var quotation = quotations[Math.floor(Math.random()*quotations.length)]
    res.io.emit("quotation", quotation );

    getPresence().then(function(presence) {
        res.io.emit("presence", presence );
    })

    /* Handle weather */
    getweather().then(function(weather) {
        res.io.emit("weather", weather.current_observation );
    })

    var ref = admin.database().ref("logger")
    ref.orderByChild('timestamp').limitToLast(1).once("value", function(snapshot) {
      res.io.emit("log", snapshot.val())
    });
    



    grabCalendar("hiromi").then(function(events) {
        key = "events-hiromi"
        console.log(key)
        res.io.emit(key, events );
        key = ""
    }).then(function() {

      grabCalendar("harper").then(function(o) {
        key = "events-harper"
        console.log(key)
        res.io.emit(key, o );
        key = ""
      })    
    });


    

    res.send('update');
});

/* timers */

var weather_update_time = 30*60*1000;

var weather_timer = setInterval(function() {
        getweather()
}, weather_update_time);

getweather()





module.exports = router;
