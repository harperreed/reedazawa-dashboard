require 'net/https'
require 'json'

images = ["2016-02-21-9.jpg", "61776506401__DA47FDF9-F946-49A5-8FFF-62A38255A745.jpg", "69720030.jpg", "IMG_0160.jpg", "IMG-20181120-WA0026.jpg", "IMG_20190729_120234.jpg", "L1000809.jpg", "L1001608.jpg", "L1002330.jpg", "L1050316.jpg"]

SCHEDULER.every '15m', :first_in => 0 do |job|
  image = "assets/slideshow/" + images.sample

  send_event('slideshow',  { :image => image })
end

