require 'net/https'
require 'json'
require "uri"


def hassconnect(state)
  api_url = ENV["API_ROOT"] + state

  uri = URI.parse(api_url)
  http = Net::HTTP.new(uri.host, uri.port)

  request = Net::HTTP::Get.new(uri.request_uri)
  request["Authorization"] = "Bearer "+ ENV["HASS_TOKEN"]
  request["User-Agent"] = "job"
  request["Accept"] = "*/*"
  request["accept-encoding"] = "none"
  response = http.request(request)
  return JSON.parse(response.body)
end
  
SCHEDULER.every '1m', :first_in => 0 do |job|
  state = "sensor.ii_usagi_battery_sensor"

  battery_sensor = hassconnect(state)
  battery_level  = Integer(battery_sensor["state"])
  
  state = "binary_sensor.ii_usagi_charger_sensor"
  charger_sensor = hassconnect(state)
  charging_state  = charger_sensor["state"]

  state = "sensor.ii_usagi_range_sensor"
  range_sensor = hassconnect(state)
  range_state  = range_sensor["state"]
  
  charging_complete = false
  charging_charging = false
  charging_not_charging = false


  if (charging_state=="off")
    charging_not_charging = true
  elsif (charging_state=="on")
    charging_charging = true
  end

  

  battery_full = false
  battery_half = false
  battery_quarter = false
  battery_empty = false

  if (battery_level>88)
    battery_full = true
  elsif (battery_level>75)
    battery_threequarters= true    
  elsif (battery_level>50)
    battery_half = true
  elsif (battery_level>25)
    battery_quarter = true
  elsif (battery_level>0)
    battery_empty = true
  end


  variables = { 
    battery_level: battery_level, 
    battery_range: range_state, 
    charging_state: charging_state,

    battery_full:battery_full,
    battery_threequarters:battery_threequarters, 
    battery_half:battery_half,
    battery_quarter:battery_quarter,
    battery_empty:battery_empty,
    charging_complete:charging_complete,
    charging_charging:charging_charging,
    charging_not_charging:charging_not_charging
  }



  send_event('teslabattery', variables) 
end
