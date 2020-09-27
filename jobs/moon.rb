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

def get_moon()
  host = "http://192.168.200.101:8123"
  state = "sensor.moon"
  response = hassconnect(state)


  img = get_image(response['state'])
  
  metadata = {
    moon: get_emoji(response['state']),
    image: '/moons/' + get_image(response['state']),
    name: get_name(response['state'])
  }
 
  
  return metadata
end

SCHEDULER.every '6h', :first_in => 0 do |job|
  metadata = get_moon()
  send_event("moon", { emoji: metadata[:moon] , image: metadata[:image] , title: metadata[:name]})
  
end


def get_emoji(phase)
  # new_moon, waxing_crescent, first_quarter, waxing_gibbous, full_moon, waning_gibbous, last_quarter or waning_crescent
  case phase
  when "new_moon"
    '🌑'
  when "waxing_crescent"
    '🌒'
  when "first_quarter"
    '🌓'
  when "waxing_gibbous"
    '🌔'
  when "full_moon"
    '🌕'
  when "waning_gibbous"
    '🌖'
  when "last_quarter"
    '🌗'
  when "waning_crescent"
    '🌘'
  else
    '🌝'
  end
end

def get_image(phase)
  # new_moon, waxing_crescent, first_quarter, waxing_gibbous, full_moon, waning_gibbous, last_quarter or waning_crescent
  case phase
  when "new_moon"
    'new-moon-symbol_1f311.png'
  when "waxing_crescent"
    'waxing-crescent-moon-symbol_1f312.png'
  when "first_quarter"
    'first-quarter-moon-symbol_1f313.png'
  when "waxing_gibbous"
    'waxing-gibbous-moon-symbol_1f314.png'
  when "full_moon"
    'full-moon-symbol_1f315.png'
  when "waning_gibbous"
    'waning-gibbous-moon-symbol_1f316.png'
  when "last_quarter"
    'last-quarter-moon-symbol_1f317.png'
  when "waning_crescent"
    'waning-crescent-moon-symbol_1f318.png'
  else
    'full-moon-with-face_1f31d.png'
  end
end

def get_name(phase)
  # new_moon, waxing_crescent, first_quarter, waxing_gibbous, full_moon, waning_gibbous, last_quarter or waning_crescent
  case phase
  when "new_moon"
    'New moon'
  when "waxing_crescent"
    'Waxing Crescent moon'
  when "first_quarter"
    'First Quarter moon'
  when "waxing_gibbous"
    'Waxing Gibbous moon'
  when "full_moon"
    'Full moon'
  when "waning_gibbous"
    'Waning Gibbous moon'
  when "last_quarter"
    'Last Quarter moon'
  when "waning_crescent"
    'Waning Crescent moon'
  else
    'mooooooon'
  end
end