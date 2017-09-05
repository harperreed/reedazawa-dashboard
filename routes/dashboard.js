var express = require('express');
var router = express.Router();
var Wunderground = require('wundergroundnode');
var yaml_config = require('node-yaml-config');
var moment = require('moment-timezone');
var admin = require("firebase-admin");
var request = require('request');

var config = yaml_config.load(__dirname + '/../config/config.yaml');


const cache = require('node-file-cache').create({"life":1800});

var wunderground = new Wunderground(config.weatherunderground.apikey);

var serviceAccount = require(__dirname +"/../config/" + config.firebase.serviceaccount_json);

var quotations = require(__dirname +"/../config/quotations.json");


admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://"+config.firebase.domain+".firebaseio.com"
});

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
    var weather_key = "weather"+ config.weatherunderground.query
    var weather = cache.get(weather_key)
    res.io.emit("weather", weather.current_observation );

    /* Handle quotation */
    var quotation = quotations[Math.floor(Math.random()*quotations.length)]
    res.io.emit("quotation", quotation );

    getPresence().then(function(presence) {
        res.io.emit("presence", presence );
    })

    res.send('update');
});

/* timers */

var weather_update_time = 30*60*1000;
console.log(weather_update_time)
var weather_timer = setInterval(function() {
        getweather()
}, weather_update_time);

getweather()


module.exports = router;
