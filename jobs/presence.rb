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
  hiromi_presence_state = "person.hiromi_nakazawa"
  harper_presence_state = "person.harper_reed"

  hiromi_response = hassconnect(hiromi_presence_state)
  harper_response = hassconnect(harper_presence_state)

  

  hiromi_lat = hiromi_response['attributes']['latitude'].to_s
  hiromi_lng = hiromi_response['attributes']['longitude'].to_s
  hiromi_location = hiromi_lat + "," + hiromi_lng

  harper_lat = harper_response['attributes']['latitude'].to_s
  harper_lng = harper_response['attributes']['longitude'].to_s
  harper_location = harper_lat + "," + harper_lng
  


  if hiromi_response['state']=="home"
    hiromi_home = true
  else
    hiromi_home = false
  end

  if harper_response['state']=="home"
    harper_home =true
  else
    harper_home = false
  end

  if harper_home && hiromi_home
    everyone_home = true
  else
    everyone_home = false
  end

  if harper_home || hiromi_home
    occupied = true
  else
    occupied = false
  end


  map_size = "700x700"

  harper_map = "https://maps.googleapis.com/maps/api/staticmap?autoscale=6&size="+map_size+"&maptype=roadmap&format=png&visual_refresh=true&markers=icon:https://reedazawa.web.app/imgs/d376ebba-2f33-4a5e-b322-1d87b2183f96.png%7Cshadow:true%7C"+harper_location+"&key="+ ENV["GOOGLE_MAPS_TOKEN"]
  hiromi_map = "https://maps.googleapis.com/maps/api/staticmap?autoscale=6&size="+map_size+"&maptype=roadmap&format=png&visual_refresh=true&markers=icon:https://reedazawa.web.app/imgs/5d93a15e-02fc-4791-ab56-06b1dd6e20d2.png%7Cshadow:true%7C"+hiromi_location+"&key="+ ENV["GOOGLE_MAPS_TOKEN"]

  hiromi = {"present"=>hiromi_home, "map_url" => hiromi_map, "caption"=>""}
  harper = {"present"=>harper_home, "map_url" => harper_map, "caption"=>""}

  people = [hiromi, harper]

  send_event('presence', { occupied: occupied, everyone_home: everyone_home , people: people})
end
