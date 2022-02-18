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


endpoint = "http://www.basketball-reference.com/players/c/currst01/gamelog/2016/" 

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

 # click on playoff page

require 'open-uri'
require 'nokogiri'
require 'uri'

base_url = "https://www.google.com/search?q=stackoverflow"
document = open(base_url)
parsed_content = Nokogiri::HTML(document.read)
href = parsed_content.css('.r').first.children.first['href']
new_url = URI.join base_url, href
new_document = open(new_url)

# translated

href = @player_page.css('.sr_preset').first.children.first['href']
new_url = URI.join @player_page, href
@player_playoff_page = open(new_url)

@player_page = Nokogiri::HTML.parse(URI.open("http://basketball-reference.com/players/d/duranke01.html"))

/players/a/abramjo01.html
/players/f/fleisje01.html
/players/h/hawkico01.html
/players/m/mutomdi01.html
/players/m/millebr01.html
/players/w/wallabe01.html
/players/d/duncati01.html

/players/j/jordami01.html
/players/j/jamesle01.html

@player_page = Nokogiri::HTML.parse(URI.open("http://basketball-reference.com/players/a/abramjo01.html"))
@player_page = Nokogiri::HTML.parse(URI.open("http://basketball-reference.com/players/f/fleisje01.html"))
@player_page = Nokogiri::HTML.parse(URI.open("http://basketball-reference.com/players/h/hawkico01.html"))
@player_page = Nokogiri::HTML.parse(URI.open("http://basketball-reference.com/players/m/mutomdi01.html"))
@player_page = Nokogiri::HTML.parse(URI.open("http://basketball-reference.com/players/d/duncati01.html"))
@player_page = Nokogiri::HTML.parse(URI.open("http://basketball-reference.com/players/m/millebr01.html"))
@player_page = Nokogiri::HTML.parse(URI.open("http://basketball-reference.com/players/w/wallabe01.html"))
@player_page = Nokogiri::HTML.parse(URI.open("http://basketball-reference.com/players/d/duranke01.html"))


player_info_template = ["player_name", "pronunciation", "full_name", "nickname", "position", "shoots", "height", "weight", "birthdate", "birthplace", "college", "high_school", "college_recruiting_rank", "draft", "nba_debut", "career_length", "experience"]
@player_info.each do |pi| 
   puts "Player Name "
end

# for image url Durant - no image for John Abramovic or Jerry Fleishman
<img itemscope="image" src="https://www.basketball-reference.com/req/202106291/images/players/duranke01.jpg" alt="Photo of Kevin Durant">

# relatives
<p><strong>Relatives</strong>: Nephew&nbsp;<a itemprop="relatedTo" href="/players/k/kabenmf01.html">Mfiondu&nbsp;Kabengele</a> </p>

# main name more specificity
<h1 itemprop="name">
		<span>Dikembe Mutombo</span>
</h1>
<p>
  <strong>
  <strong>Dikembe Mutombo</strong>
  </strong>
    
  ▪
  <a href="/friv/twitter.html">Twitter</a>:
  <a href="https://twitter.com/officialmutombo">officialmutombo</a>
</p>
<p>
   <span class="desc">(born Dikembe Mutombo Mpolondo Mukamba Jean-Jacques Wamutombo)</span>
</p>
<p>
(Deke, Mt. Mutombo)
</p>
<p>
  <strong>
  Position:
  </strong>
  Center


  
  ▪
  
  <strong>
  Shoots:
  </strong>
  Right
</p>

# Connie Hawkins ABA

<p>
  <strong>NBA Debut: </strong><a href="/boxscores/196910160PHO.html">October 16, 1969</a>&nbsp;▪&nbsp;<strong>ABA Debut: </strong><a href="/boxscores/196710230NJA.html">October 23, 1967</a>
</p>

# Achievements
<li class="important special"><a>Hall of Fame</a></li>
<li class="all_star"><a>15x All Star</a></li>
<li class=""><a>5x NBA Champ</a></li>
<li class=""><a>15x All-NBA</a></li>
<li class=""><a>15x All-Defensive</a></li>
<li class=""><a>1997-98 All-Rookie</a></li>
<li class=""><a>1997-98 ROY</a></li>
<li class=""><a>3x Finals MVP</a></li>
<li class=""><a>1999-00 AS MVP</a></li>
<li class=""><a>2x MVP</a></li>
<li class=""><a>NBA 75th Anniv. Team</a></li>

# Mutumbo
<li data-tip="2x NBA TRB Champ" class=" poptip"><a>2x TRB Champ</a></li>
<li data-tip="3x NBA BLK Champ" class=" poptip"><a>3x BLK Champ</a></li>
<li class=""><a>4x Def. POY</a></li> 

#Aaron Mckie /players/m/mckieaa01.html
<li class=""><a>2000-01 Sixth Man</a></li>

# Durant
<li data-tip="4x NBA Scoring Champ" class=" poptip"><a>4x Scoring Champ</a></li>

# Steve Nash /players/n/nashst01.html
<li data-tip="5x NBA AST Champ" class=" poptip"><a>5x AST Champ</a></li>

#Julius Randle /players/r/randlju01.html
<li class=""><a>2020-21 Most Improved</a></li>

# Jimmy Butler /players/b/butleji01.html
<li data-tip="2020-21 NBA STL Champ" class=" poptip"><a>2020-21 STL Champ</a></li>







@player_name
@player_pronunciation
@player_full_name
@player_nickname
@player_position
@player_shoots
@player_height
@player_weight
@player_birthdate
@player_birthplace
@player_college
@player_high_school
@player_college_recruiting_rank
@player_draft
@player_nba_debut
@player_career_length
@player_experience



@info.at('strong:contains("Position")').next_element.text.strip