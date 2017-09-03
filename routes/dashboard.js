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
        ref.orderByChild('timestamp').limitToLast(5).once("value", function(snapshot) {
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
router.get('/logs', function(req, res, next) {
    getLogs().then(function(data) {
        return data
    }).then(function(data){
        res.send(data)
    })
    .catch(next)
});

/* GET home page. */
router.get('/presence', function(req, res, next) {
    p = []
    getPresence().then(function(data) {
        //res.send(data)
        return data
    }).then(function(data2){
        res.send(data2)

    })
    .catch(next)
});

/* GET home page. */
router.get('/weather', function(req, res, next) {
    
    getweather().then(function(data) {

        return data.current_observation
    }).then(function(data){
        res.send(data)
        
    })
    .catch(next)

});

/* GET home page. */
router.get('/', function(req, res, next) {

    var time = moment().tz(config.timezone).format('LT')
        
    weather = null
    presence = null
    logs = null

    getweather().then(function(data) {
        weather = data.current_observation
         
        presence =getPresence()
        return getPresence()
    }).then(function(data){
        presence = data
        return presence
    }).then(function(data){
        quotation = quotations[Math.floor(Math.random()*quotations.length)]
        variables = {
            title: config.title, 
            temp: weather.temp_f, 
            weather: weather.weather, 
            weathericon: weather.icon_url,
            presence: presence,
            logs:logs,
            time:time,
            day: moment().format('dddd'),
            hour: 5,//moment().format('k'),
            quotation:quotation
        }
        console.log(variables);

        res.render('dashboard', variables);
    })
    .catch(next)

    
    //res.render('dashboard', { title: 'Express', temp: weather.temp_f});
   
});

module.exports = router;
