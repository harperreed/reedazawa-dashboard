var express = require('express');
var router = express.Router();
var Wunderground = require('wundergroundnode');
var yaml_config = require('node-yaml-config');
var moment = require('moment-timezone');

var config = yaml_config.load(__dirname + '/../config/config.yaml');

var wunderground = new Wunderground(config.weatherunderground.apikey);

function getweather() {
        return new Promise(function(resolve,reject) {
            wunderground.conditions().request(config.weatherunderground.query, function(err, response){
                weather = response
                resolve(weather);
            });
        });
    }


/* GET home page. */
router.get('/weather', function(req, res, next) {
    var weather = []
    var time = moment().tz(config.timezone).format('LT')

    getweather().then(function(data) {

        return data.current_observation
    }).then(function(data){
        res.send(data)
        
    })
    .catch(next)

});

/* GET home page. */
router.get('/', function(req, res, next) {

    var time = moment().format('LT')
        

    getweather().then(function(data) {

        return data.current_observation
    }).then(function(data){
        //res.send(data)
        weather = data
        variables = {
            title: 'Reedazawa Dashboard', 
            temp: weather.temp_f, 
            weather: weather.weather, 
            weathericon: weather.icon_url,
            time:time
        }
        console.log(variables)
        res.render('dashboard', variables);
    })
    .catch(next)


    
    //res.render('dashboard', { title: 'Express', temp: weather.temp_f});
   
});

module.exports = router;
