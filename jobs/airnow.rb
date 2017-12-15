require 'net/https'

# USA Only
ZIP_CODE = 60612

# create free account on https://docs.airnowapi.org/
api_key = ENV["REEDAZAWA_API_TOKEN"]

SCHEDULER.every '5m', :first_in => 0 do |job|
  api_url = ENV["API_ROOT"] + "purple"
  uri = URI.parse(api_url)
  post_data = {"api_key" => api_key}
  response = Net::HTTP.post_form(uri, post_data)


  air_data     = JSON.parse(response.body)

  aqi          = air_data['AQI']['PM2.5']


  send_event('airnow',  { :aqi          => aqi,
                          :color        => aqi_color(aqi),
                          :desc        => aqi_desc(aqi),
                          :icon         => aqi_icon(aqi), })
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
