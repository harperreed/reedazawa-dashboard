require 'net/https'
require 'json'
require "uri"


api_key = ENV["REEDAZAWA_API_TOKEN"]
  
SCHEDULER.every '1m', :first_in => 0 do |job|
  api_url = ENV["API_ROOT"] + "presence"
  uri = URI.parse(api_url)
  post_data = {"api_key" => api_key}
  response = Net::HTTP.post_form(uri, post_data)

  presence = JSON.parse(response.body)  


  occupied = presence["occupied"]
  everyone_home = presence["everyone_home"]
  people = []

  presence["people"].each do |person|
    if (person['guest'] != true)
      person["caption"] = "fuck yea"
      person['name'] = person["full_name"].split[0]

      if (person['location']['inTransit']==nil)
        person["caption"] = person["name"] + ' is in transit'
      elsif (person['location']['name'] != nil)
        person["caption"] = person["name"] + ' is at ' + person["location"]["name"]
      else
        person["caption"] = person["name"]  + ' is at ' + person["location"]["address1"] + ', ' + person["location"]["address2"]
      end

      person["location"]["map_url"] = person["location"]["map_url"].gsub("400x300","650x400")

      people.push(person)
    end
  end



  send_event('presence', { occupied: occupied, everyone_home: everyone_home, people: people})
end
