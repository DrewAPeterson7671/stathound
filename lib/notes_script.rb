## The Walkthrough

# Add gems  

require 'pry-rails'
require 'watir'
require 'nokogiri'

# Go to Google

browser = Watir::Browser.new(:chrome) 
browser.goto("google.com") 
browser.html 

#Show html of current page 

browser.url 
# Shows current page url 
browser.back 
# Back button 
browser.close 
# Close Browser

doc = Nokogiri::HTML.parse(browser.html) 
# Imports the XML into ruby object 
# Queriable by css selectors 

doc.css("a") 
# Queries the doc for anchor links and returns array with all matching items. 

doc.css("a").count 
# Returns a count of all instances on the doc 

doc.at_css("a") 
# Returns only first matching item returned as the element instead of an array 

doc.at_css("a:nth-child(3)") 
# Returns first nth child 3 element 

doc.at_css("a:nth-child(3)").text 
# Returns the text only 


### Scraping Static Content ###


endpoint = "http:www.basketball-reference.com/players/c/currst01/gamelog/2016/" 

URI.open(endpoint) 
doc = Nokogiri::HTML.parse(URI.open(endpoint)) 
doc.css("table").count 

# 12 tables present 
# Most likely, the tables we want on the page are large 

doc.css("table").sort { |x, y| y.css("tr").count <=> x.css("tr").count } 
# This will sort the tables 

games_table = doc.css("table").sort { |x, y| y.css("tr").count <=> x.css("tr").count }.first 
# Grab 1st of the sort and save as games_table 

# Now we want the rows 

rows = game_table.css("tr") 
# Let's check against the number of rows on the page.  Shows 82 on the table. 

rows.count 
# returns 87.  We have some headers and missed games. 

rows = rows.select { |row| row.css("th").empty? } 
# Screens out the row headers 

rows.count 
# Returns 82 

# We want to grab 3p attempted and made, rows 14 and 15 

data = rows.map do |row| 
   [row.at_css("td:nth-child(14)").try(:text), row.at_css("td:nth-child(15)").try(:text)] 
end
# Try returns nil instead of error if the harvested data has a problem 
# Worked but contains nils for missed games 

data = data.reject { |tuple| tuple[0].nil? } 
# Screens out the nils 


### 2 Dynamic Content ###
 

# Has warriors roster, wants image for each player 
# warriors_roster 
# An array of warriors names for the roster, pre made 

browser.goto("images.google.com") 
# Need a unique identifier 

# Title is Search 
browser.text_field(title: "Search").set "Steph Curry" 

# Writes Steph Curry into the search field 
# Find unique identifier for the search button 

browser.button(type: "submit").click 

# Images load with JS, doesn't make an http request, loads dynamically 

sleep 1 
# Pause for the page to load. 

warriors_player_images = warriors_roster.map do |player| 
   browser.goto("images.google.com") 
   browser.text_field(title: "Search").set player 
   browser.button(type: "submit").click 
   sleep 1 
   doc = Nokogiri::HTML.parse(browser.html) 
   doc.at_css("div#ires img")["src"] 
 end 