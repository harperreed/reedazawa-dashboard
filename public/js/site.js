 var getDeviceTelemetry = function () 
    {
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
    }


$(document).ready(function() {



    getDeviceTelemetry();
});