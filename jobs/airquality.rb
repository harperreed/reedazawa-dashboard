require 'net/https'
require 'json'

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


SCHEDULER.every '10m', :first_in => 0 do |job|
  state = "sensor.purpleair"
  airquality = hassconnect(state)

  aqi          = airquality['state']

  object = { 
    :title => "Air Quality", 
    :current          => aqi,
    :color        => aqi_color(aqi),
    :moreinfo        => aqi_desc(aqi),
    :icon         => aqi_icon(aqi), 
  }

  send_event('airquality', object )
end


def aqi_color(aqi)
  case aqi.to_i
  when 0..50
    'YellowGreen'
  when 51..100
    'gold'
  when 101..150
    'orange'
  when 151..200
    'red'
  when 201..300
    'darkred'
  else
    'maroon'
  end
end

def aqi_desc(aqi)
  case aqi.to_i
  when 0..50
    'Good'
  when 51..100
    'Moderate'
  when 101..150
    'Unhealthy for sensitive groups'
  when 151..200
    'Unhealthy'
  when 201..300
    'Very unhealthy'
  else
    'Hazardous'
  end
end

def aqi_icon(aqi)
  case aqi.to_i
  when 0..50
    'icon-smile'
  when 51..100
    'icon-stethoscope'
  when 101..150
    'icon-ambulance'
  when 151..200
    'icon-frown'
  when 201..300
    'icon-meh'
  else
    'icon-trash'
  end
end
