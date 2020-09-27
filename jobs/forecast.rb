require 'net/https'
require 'json'
require 'date'

# Forecast API Key from https://developer.forecast.io
forecast_api_key = ENV["FORECASTIO_KEY"]

# Latitude, Longitude for location
forecast_location_lat = ENV["LAT"]
forecast_location_long = ENV["LNG"]

# Unit Format
# "us" - U.S. Imperial
# "si" - International System of Units
# "uk" - SI w. windSpeed in mph
forecast_units = "us"
  
SCHEDULER.every '10m', :first_in => 0 do |job|
   http = Net::HTTP.new("api.forecast.io", 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    forecast_url = "/forecast/#{forecast_api_key}/#{forecast_location_lat},#{forecast_location_long}?units=#{forecast_units}"

    response = http.request(Net::HTTP::Get.new(forecast_url))

    forecast = JSON.parse(response.body)  
    
    forecast_current_temp = forecast["currently"]["temperature"].round
    forecast_current_icon = forecast["currently"]["icon"]
    forecast_current_desc = forecast["currently"]["summary"]
    if forecast["minutely"]  # sometimes this is missing from the response.  I don't know why
        forecast_next_desc  = forecast["minutely"]["summary"]
        forecast_next_icon  = forecast["minutely"]["icon"]
    else
        puts "Did not get minutely forecast data again"
        forecast_next_desc  = "No data"
        forecast_next_icon  = ""
    end
    forecast_later_desc   = forecast["hourly"]["summary"]
    forecast_later_icon   = forecast["hourly"]["icon"]
  
    week = forecast["daily"]['summary']
    today = forecast["daily"]["data"][0]

    forecast_current_temp = forecast["currently"]["temperature"].round

    

    case forecast_current_temp
    when -40..0
        temp_words = "cold af"
    when 0..32
        temp_words = "freezing"
    when 32..40
        temp_words = "pretty cold"
    when 40..60
        temp_words = "chilly"
    when 60..70
        temp_words = "sorta chilly"
    when 70..75
        temp_words = "perfect"
    when 75..80
        temp_words = "warm"
    when 80..90
        temp_words = "hot"
    when 90..120
        temp_words = "hot af"
    end


    case today['uvIndex']
    when 0..2
        uv_words = "Low"
    when 3..5
        uv_words = "Moderate"
    when 6..7
        uv_words = "High"
    when 8..100
        uv_words = "Very high"
    
    end


    temp =  " The temperature today is going to be " + temp_words + ". "
    summary =  "Today, " + today['summary'] + temp +"<br><br>" + week 
    forecast_current_temp = forecast["currently"]["temperature"].round
    forecast_hour_summary = forecast["minutely"]["summary"]
    payload = { 
        temperature: "#{forecast_current_temp}&deg;",
        hour: "#{forecast_hour_summary}",
        todayHigh: "#{today['apparentTemperatureHigh'].round}&deg;",
        todayNow: "#{forecast["currently"]["temperature"].round}&deg;",
        todayLow: "#{today['apparentTemperatureLow'].round}&deg;",
        todayHighTime: "High @ #{Time.at(today['apparentTemperatureHighTime']).to_datetime.to_datetime.strftime("%l:%M %P") }",
        todayLowTime: "Low @ #{Time.at(today['apparentTemperatureLowTime']).to_datetime.strftime("%l:%M %P") }",
        todayNowTime: "Now @ #{Time.at(today['apparentTemperatureLowTime']).to_datetime.strftime("%l:%M %P") }",
        current_temp: "#{forecast_current_temp}&deg;", 
        current_icon: "#{forecast_current_icon}", 
        current_desc: "#{forecast_current_desc}", 
        next_icon: "#{forecast_next_icon}", 
        next_desc: "#{forecast_next_desc}", 
        later_icon: "#{forecast_later_icon}", 
        later_desc: "#{forecast_later_desc}"
    }
    send_event('forecast', payload)
    send_event('prosecast', { summary: summary})
    send_event('uvindex',  { :current => today['uvIndex'], :moreinfo  => uv_words, :title=>"UV Index" })

end
