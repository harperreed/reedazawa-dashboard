 var getDeviceTelemetry = function () 
    {
        if (typeof okular === 'undefined' || okular === null) {
            var battery = 0;
        }else {
            var s = okular.DevicesStatus()[okular.session_uuid]
            var battery = okular.BatteryLevel
        }
        var battery_html = battery +"% "

        if (battery>90){
            battery_html = battery_html + '<i class="fa fa-battery-full" aria-hidden="true"></i>'
        }else if (battery>75){
            battery_html = battery_html + '<i class="fa fa-battery-three-quarters" aria-hidden="true"></i>'
        }else if (battery>50){
            battery_html = battery_html +'<i class="fa fa-battery-half" aria-hidden="true"></i>'
        }else if (battery>25){
            battery_html = battery_html +'<i class="fa fa-battery-quarter" aria-hidden="true"></i>'
        }else if (battery>=0){
            battery_html = battery_html +'<i class="fa fa-battery-empty" aria-hidden="true"></i>'
        }
        $("#battery").html(battery_html)
    }

var getQuotation = function () {
    $.getJSON( "/dashboard/quotation", function( data ) {
        console.log(data)
        $('#quotation #quote').text(data.quotation);
        $('#quotation #author').text(data.author);
    });
}

var changeGreeting = function () {
    $.get( "/dashboard/greeting", function( data ) {
        if ($('#greeting').html()==data){
          console.log("greeting stays the same")
        }else{
          console.log("update greeting")
          $('#greeting').html(data);
        }
        
    });
}

var getPresence = function () {
    $.get( "/dashboard/presence", function( data ) {
        if ($('#presence').html()==data){
          console.log("presence stays the same")
        }else{
          console.log("presence greeting")
          $('#presence').html(data);
        }
        
    });
}

var getWeather = function () {
    $.getJSON( "/dashboard/weather", function( data ) {
        if ($('#weather #temperature').text()==data.temp_f){
          console.log("don't change temp")
        }else{
          console.log("change temp")
          $('#weather #temperature').text(data.temp_f);
        }
        if ($('#weather #icon').text()==data.icon_url){
          console.log("don't change icon")
        }else{
          console.log("change icon")
          $('#weather #icon').text(data.icon_url);
        }
        $('#weather #icon').text(data.icon_url);
    });
}


$(document).ready(function() {
    getDeviceTelemetry();
    var update_time = 6000;
    var timer = setInterval(function() {
        getDeviceTelemetry();
        getQuotation();
        getWeather();
        getPresence();
        changeGreeting();
    }, update_time);
});