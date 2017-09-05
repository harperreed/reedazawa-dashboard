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

var updateHeader = function () {
  today = new Date();
  weekday = today.getDay();
  switch(weekday) {
    case 1:
        icon = "hand-rock-o"
        break;
    case 2:
        icon = ""
        break;
    case 3:
        icon = ""
        break;
    case 4:
        icon = ""
        break;
    case 5:
        icon = "rocket"
        break;
    case 6:
        icon = "diamond"
        break;
    case 7:
        icon = ""
        break;                

    default:
        icon = ""
        break;    
    }
  if (icon !=""){
    $("#header-icon").html('<i class="fa fa-'+icon+'" aria-hidden="true"></i>')  
  }
}

var updateGreeting = function () {
  today = new Date();
  hour = today.getHours();
  console.log(hour)
  if (hour < 7){
    greeting = "🔥 Good Morning, early riser! 🔥";
  }
  else if (hour < 10){
    greeting = "Good Morning. Have a great day";
  }
  else if (hour < 11){
    greeting = "Good Morning.";
  }
  else if (hour <= 12){
    greeting = "Go get Lunch";
  }
  else if (hour < 17){
    greeting = "Good Afternoon";
  }
  else if (hour <= 22){
    greeting = "Good Evening";
  }
  else if (hour <= 23){
    greeting = "Good Night";
  }
  else if (hour < 24){
    greeting = "😴 It's late, Go to Bed! 😴";
  }
  if ($("#greeting").html()!=greeting){
    $("#greeting").html(greeting);  
  }
  
}

var triggerUpdates = function(){
  $.get( "/dashboard/update", function( data ) {
    console.log(data)
  });
}

var runUpdate = function () {
  getDeviceTelemetry();
  updateHeader();
  updateGreeting();
  triggerUpdates();
}

$(document).ready(function() {


    var update_time = 600000; //every ten minutes. i think
    //var update_time = 10000;
    var timer = setInterval(function() {
        runUpdate()
    }, update_time);

    runUpdate();
});