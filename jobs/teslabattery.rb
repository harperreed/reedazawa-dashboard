require 'net/https'
require 'json'
require "uri"


api_key = ENV["REEDAZAWA_API_TOKEN"] 
  
SCHEDULER.every '1m', :first_in => 0 do |job|
  api_url = ENV["API_ROOT"] + "tesla"
  uri = URI.parse(api_url)
  post_data = {"api_key" => api_key}
  response = Net::HTTP.post_form(uri, post_data)

  tesla = JSON.parse(response.body)  

  
  battery = tesla["charge_state"]
  battery_level = Integer(battery["battery_level"])
  battery_range = battery["battery_range"]
  charging_state = battery["charging_state"]
  
  charging_complete = false
  charging_charging = false
  charging_not_charging = false



  if (charging_state=="Complete")
    charging_complete = true
  elsif (charging_state=="Disconnected")
    charging_not_charging = true
  elsif (charging_state=="Charging")
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
    battery_range: battery_range, 
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