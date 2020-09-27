require 'net/https'
require 'json'


SCHEDULER.every '10m', :first_in => 0 do |job|
  day = Date.today.strftime("%A")
  num = Date.today.wday 

  send_event('weekprogress',  { :min => 0, :max  => 7, :value => num, :moreinfo=>Date.today.strftime("%A") })
end

