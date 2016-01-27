require 'rubygems'
require 'nokogiri' 
require 'open-uri'
require 'json'
require 'pry'

page = Nokogiri::HTML(open("http://www.census.gov/schools/facts/alabama.html"))   

state_names_elements = page.css('#pickState option')

state_names = state_names_elements.each_with_object([]) do |element, names_array|
  names_array << element.text
end

state_names = state_names[2..-1]

state_data = {}

state_names.each do |state|
  state_slug = state.split(' ').join('_').downcase
  url = "http://www.census.gov/schools/facts/#{state_slug}.html"
  page = Nokogiri::HTML(open(url))
  population = page.css('.population td')
  business = page.css('.business td')
  pop = population[2].text.split(',').join.to_i
  comp = population[-1].text.split('%')[0].to_f
  amusement_parks = business[5].text.to_i
  public_transit = population[-6].text.split('%')[0].to_f
  state_data[state_slug] = {
    "population" => pop, 
    "home_computer" => comp, 
    "amusement_parks" => amusement_parks, 
    "public_transit_riders" => public_transit
  }
end

output = File.open('state_dictionary.py', 'w')
output << JSON.generate(state_data)
output.close

output = File.open('state_data.html', 'w')
output << "<!DOCTYPE html><html><head><body><table><tr><th>State</th><th>Population (2014)</th><th>% of People with Home Computers (2014)</th><th>Number of Amusement Parks (2013)</th><th>% of People Who Ride Public Transit (2013)</th></tr>"

state_data.each do |state, data|
  state_unslug = state.split("_").map(&:capitalize).join(" ")
  output << "<tr><td>#{state_unslug}</td><td>#{data["population"]}</td><td>#{data["home_computer"]}</td><td>#{data["amusement_parks"]}</td><td>#{data["public_transit_riders"]}</td></tr>"
end

output << "</table></body></html>"

output.close




