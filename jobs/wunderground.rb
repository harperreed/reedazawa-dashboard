require 'net/https'
require 'json'

# wunderground API Key from https://developer.wunderground.io
wunderground_api_key = ENV["WUNDERGROUND_TOKEN"]

# Latitude, Longitude for location
wunderground_location_lat = ENV["lat"]
wunderground_location_long = ENV["lng"]
wunderground_pws = ENV["WUNDERGROUND_PWS"]

SCHEDULER.every '2h', :first_in => 0 do |job|
  http = Net::HTTP.new("api.wunderground.com", 443)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  response = http.request(Net::HTTP::Get.new("/api/#{wunderground_api_key}/hourly/q/pws:#{wunderground_pws}.json"))
  wunderground = JSON.parse(response.body)  

  wunderground_current_temp = wunderground["hourly_forecast"][0]["temp"]["english"]
  wunderground_current_icon = wunderground["hourly_forecast"][0]["icon_url"]
  wunderground_current_desc = wunderground["hourly_forecast"][0]["condition"]
  wunderground_next_desc  = wunderground["hourly_forecast"][1]["condition"]
  wunderground_next_icon  = wunderground["hourly_forecast"][1]["icon_url"]
  wunderground_later_desc   = wunderground["hourly_forecast"][5]["condition"]
  wunderground_later_icon   = wunderground["hourly_forecast"][5]["icon_url"]
  send_event('wunderground', { current_temp: "#{wunderground_current_temp}&deg;", current_icon: "#{wunderground_current_icon}", current_desc: "#{wunderground_current_desc}", forecase: wunderground})
  send_event('wuforecast', { forecast: wunderground["hourly_forecast"].first(5)})
end