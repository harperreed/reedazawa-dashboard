require 'open-uri'
require 'json'

images = Array.new


def get_images()
    @jsonresults = open("https://api.flickr.com/services/feeds/photos_public.gne?id=50406951@N00&format=json&nojsoncallback=1").read
    @images = JSON.parse(@jsonresults)
    images = @images['items']
    return images
end

def choose_image(images)
    image = images[rand(images.length)]
    return image['media']['m']
end

puts get_images()

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '60m', :first_in => 0 do |job|
    images = get_images()
end

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '5s', :first_in => 0 do |job|
    if images
        image = choose_image(images)
        send_event('reedazawa', { "image"=>image })
    end
end