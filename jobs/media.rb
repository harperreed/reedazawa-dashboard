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

def get_now_playing()
  host = "http://192.168.200.101:8123"
  state = "media_player.kitchen"
  response = hassconnect(state)

  media_info = response['attributes']
  if response['state'] != 'idle'
  
    percentage = (media_info['media_position'].to_f / media_info['media_duration'].to_f) * 100

    image_url =  host + media_info['entity_picture']
    if media_info['media_artist']
      media_string = media_info['media_title'] + " - " + media_info['media_artist']
    else
      media_string = media_info['media_title']
    end
    
    metadata = {
      length: Time.at(media_info['media_duration']).utc.strftime('Length: %H:%M:%S'),
      duration: media_info['media_duration'],
      position: percentage.round(),
      album_art: image_url,
      artist: media_info['media_artist'],
      title: media_info['media_title'],
      state: player_status(response['state']),
      media_string: media_string
    }

  else
    metadata = nil
  end
    
  return metadata
end

SCHEDULER.every '10s', :first_in => 0 do |job|
  metadata = get_now_playing()
  if metadata
    payload = { 
      image: metadata[:album_art], 
      text: metadata[:media_string], 
      duration: metadata[:duration],
      length: metadata[:length],
      position: metadata[:position],
      status: metadata[:state],
      artist: metadata[:artist],
      title: metadata[:title] 

    }
    
  else
    payload = { 
      image: "", 
      text: "", 
      status: "Nothing Playing",
      artist: "",
      title: "",
      moreinfo: "Start some music!"
    }

  end

  send_event("media", payload)
end


def player_status(state)
  case state
  when "playing"
    'Now playing'
  when "paused"
    'Currently Paused'
  else
    'maroon'
  end
end