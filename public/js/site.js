 var getDeviceTelemetry = function () 
    {
        if (typeof okular === 'undefined' || okular === null) {
            var battery = 0;
        }else {
            var s = okular.DevicesStatus()[okular.session_uuid]
            var battery = okular.BatteryLevel
        }

        if (battery>90){
            $("#battery").html('<i class="fa fa-battery-full" aria-hidden="true"></i>')
        }else if (battery>75){
            $("#battery").html('<i class="fa fa-battery-three-quarters" aria-hidden="true"></i>')
        }else if (battery>50){
            $("#battery").html('<i class="fa fa-battery-half" aria-hidden="true"></i>')
        }else if (battery>25){
            $("#battery").html('<i class="fa fa-battery-quarter" aria-hidden="true"></i>')
        }else if (battery>0){
            $("#battery").html('<i class="fa fa-battery-empty" aria-hidden="true"></i>')
        }
    }


$(document).ready(function() {



    getDeviceTelemetry();
});