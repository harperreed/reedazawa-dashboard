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


$(document).ready(function() {



    getDeviceTelemetry();
});