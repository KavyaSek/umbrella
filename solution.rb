require "dotenv/load"
require "http"
require "json"
require "awesome_print"


## get and store location
pp "What is your location?"
location = gets.chomp

## google maps api, to update lat and lng
gmaps_key = ENV.fetch("GMAPS_KEY")
gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{location}&key=#{gmaps_key}"
gmaps_raw_response = HTTP.get(gmaps_url)
gmaps_parsed_response = JSON.parse(gmaps_raw_response)
lat = gmaps_parsed_response.fetch("results")[0].fetch("geometry").fetch("location").fetch("lat")
lng = gmaps_parsed_response.fetch("results")[0].fetch("geometry").fetch("location").fetch("lng")

## pirate weather api
pw_key = ENV.fetch("PW_KEY")
pw_url = "https://api.pirateweather.net/forecast/#{pw_key}/#{lat},#{lng}"
pw_raw_response = HTTP.get(pw_url)
pw_parsed_response = JSON.parse(pw_raw_response)
temp = pw_parsed_response.fetch("currently").fetch("temperature")
pp "You are in #{location} and the current temperature is #{temp}"


## precipitation array for the next 12 hours
prec_twelve_hours = []

i=0
while i<12
  prec_twelve_hours [i]= pw_parsed_response.fetch("hourly").fetch("data")[i].fetch("precipProbability")
  i=i+1
end

found = false
prec_twelve_hours.each_with_index do |value, index|
  if value > 0.1
    pp "The precipitation probability in the next #{index+1} hours is #{value}. You might want to carry an umbrella!"
    found = true
    break
  end
end

pp "You probably won’t need an umbrella today" unless found
