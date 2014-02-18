require 'open-uri'
require 'nokogiri'

route = "66"
stop_id = "15206"


def get_predictions(route, stop_id)
    url = "http://chicago.transitapi.com/bustime/map/getStopPredictions.jsp?stop=#{stop_id}&route=#{route}"

    source = open(url).read
    doc = Nokogiri::HTML(source)
    results = Array.new()
    directions = doc.css('stop pre').each do |dir|
        prediction = dir.css('pt').text
        vehicle = dir.css('v').text
        final_destination = dir.css('fd').text
        results << { "prediction"=>prediction,"final_destination"=>final_destination, "route_number"=>route, "vehicle_number"=>vehicle }
    end
    return results
end

puts get_predictions(route, stop_id)

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '2m', :first_in => 0, allow_overlapping: false do |job|
  results =get_predictions(route, stop_id)
  send_event('ctabus', {"predictions"=>results , "title"=>"Chicago Bus ##{route}"})
end