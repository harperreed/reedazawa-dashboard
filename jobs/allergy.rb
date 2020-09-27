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


SCHEDULER.every '30m', :first_in => 0 do |job|
  state = "sensor.allergy_index_today"
  allergies = hassconnect(state)
  info = allergies['attributes']
 
  index = allergies['state']

  send_event('allergy',  { :current => index, :moreinfo  => info['rating'], :title=>"Allergens" })
end

