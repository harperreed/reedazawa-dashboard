 var getDeviceTelemetry = function () 
    {
        if (typeof okular === 'undefined' || okular === null) {
            var battery = 90;
        }else {
            var s = okular.DevicesStatus()[okular.session_uuid]
            if (typeof(okular)!=="undefined") {
                $("#UUID").text(okular.session_uuid);
                $("#RSSI").text(okular.RSSI);
                $("#BATT").text(okular.BatteryLevel);
                $("#TEMP").text(okular.Temperature);
                
                if (s.hasOwnProperty('FirmwareRevision'))  {
                    $("#FW_version").text(s["FirmwareMajor"] + "."+ s["FirmwareMinor"] + "." + s["FirmwareRevision"]);
                } else if (s.hasOwnProperty('ApplicationVersion')) {
                    $("#FW_version").text(s["ApplicationVersion"]);
                } else {
                    $("#FW_version").text("No data.");
                }

            } else {
                $("#UUID").text("unsupported");
                $("#RSSI").text("unsupported");
                $("#BATT").text("unsupported");
                $("#TEMP").text("unsupported");
                $("#FW_version").text("unsupported");
            }
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