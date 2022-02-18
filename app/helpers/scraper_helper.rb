module ScraperHelper
  
  def test_test(name)
    "Hello #{name}!"
  end

  def target_scrape(url)
    # browser = Watir::Browser.new(:chrome)
    # browser.goto(url)
    doc = Nokogiri::HTML.parse(URI.open(url))
  end
  
  def league_year_prefix(year, league = 'NBA')
    # aba_seasons = 1968..1976
    baa_seasons = 1947..1949
    baa_seasons.include?(year) ? league_year = "BAA_#{year}" : league_year = "#{league}_#{year}"
  end

  def players_total_of_season(year, league = 'NBA')
    # always the latter year of the season, first year is 1947 no quotes
    # ABA is 1968 to 1976
    league_year = league_year_prefix(year, league)
    @doc_season = target_scrape("http://basketball-reference.com/leagues/#{league_year}_totals.html")
  end

  def players_advanced_of_season(year, league = 'NBA')
    #always the latter year of the season, first year is 1947
    league_year = league_year_prefix(year, league)
    @doc_season = target_scrape("http://basketball-reference.com/leagues/#{league_year}_advanced.html")
  end

  def players_adj_shooting_of_season(year, league = 'NBA')
    #always the latter year of the season, first year is 1947
    league_year = league_year_prefix(year, league)
    @doc_season = target_scrape("http://basketball-reference.com/leagues/#{league_year}_adj_shooting.html")
  end

  def player_list_from_season
    @name_list = []
    player_season_table = @doc_season.css("tbody")
    player_season_table.search('tr.thead').each(&:remove)
    rows = player_season_table.css("tr")
    rows.each do |r|
      # @name_list << r.at_css("td").try(:text)
      @name_list << r.at_css("a").attributes["href"].try(:value)
    end
    @name_list = @name_list.uniq
    # In 1947 should yield 161 players
  end

  def gather_players_from_season
    @name_list.each do |nl|
      get_player_page(nl)
    end
  end

  def get_player_page(player_url)
    @player_page = Nokogiri::HTML.parse(URI.open("http://basketball-reference.com#{player_url}"))
  end

  def get_player_info # Not yet attempted
    # This page has a click to show that may be an issue
    @info = @player_page.css("div#info")
    @player_info = []

    @player_info << @info.at_css("span").try(:text)
    @info.at('p:contains("Pronunciation:")') ? @player_info << @info.at('p:contains("Pronunciation:")').children.try(:text).gsub("Pronunciation:", "").gsub("\n", "").gsub(" ", "").strip : @player_info << "None"
    ## Mutumbo has "\\" before and after.  Keep?
    ## if statement doesn't seem to work
    @player_info << @info.at_css("strong").try(:text).gsub("\n  ", "")
    # Mutumbo took "Pronunciation" instead of full name
    @player_info << @info.at_css("p:nth-child(3)").try(:text).gsub("\n", "").gsub("(", "").gsub(")", "")
    # on Motumbo gives his full name and includes twitter
    # Test Existence if it contains Position or (born which is class="desc"
    # Check what this child would yield if no nickname, then check for that
    # Nickname is causing the nth-child number to shift on non-nickname players
    # Motumbo has a (born... above his nickname - test for that
    @player_position_shoot = @info.at('p:contains("Position:")').try(:text).gsub("\n", "").gsub("  ", "").split("▪")
    @player_info << @player_position_shoot[0].gsub("Position:", "")
    @player_info << @player_position_shoot[1].gsub("Shoots:", "") if @info.at('p:contains("Shoots:")')
    @player_info << @info.at("//span[@itemprop = 'height']").children.try(:text)
    @player_info << @info.at("//span[@itemprop = 'weight']").children.try(:text)
    @player_info << @info.at("//span[@itemprop = 'birthDate']").children.try(:text).gsub("\n   ", "").strip.squeeze(" ")
    @player_info << @info.at("//span[@itemprop = 'birthPlace']").children.try(:text).gsub("\n    in ", "")
    @player_info << @info.at('p:contains("College:")').children.try(:text).gsub("College:", "").gsub("\n", "").strip if @info.at('p:contains("College:")')
    @player_info << @info.at('p:contains("High School:")').children.try(:text).gsub("High School:", "").gsub("\n", "").strip if @info.at('p:contains("High School:")')
    @info.at('p:contains("Recruiting Rank:")') ? @player_info << @info.at('p:contains("Recruiting Rank:")').children.try(:text).gsub("Recruiting Rank:", "").gsub("\n", "").strip : @player_info << "None"
    @info.at('p:contains("Draft:")') ? @player_info << @info.at('p:contains("Draft:")').children.try(:text).gsub("Draft:", "").gsub("\n", "").gsub(" ", "").strip : @player_info << "Undrafted"
    @player_info << @info.at('p:contains("NBA Debut:")').children.try(:text).gsub("NBA Debut:", "").gsub("\n", "").strip
    # Connie Hawkins had ABA debut, messed up NBA debut 
  
    @player_info << @info.at('p:contains("Career Length:")').children.try(:text).gsub("Career Length:", "").gsub("\n", "").gsub(" ", "").strip if @info.at('p:contains("Career Length:")')
    # on Durant, gave Ben Wallace numbers

    @player_info << @info.at('p:contains("Experience:")').children.try(:text).gsub("Experience:", "").gsub("\n", "").gsub(" ", "").strip if @info.at('p:contains("Experience:")')

    ## Review each line to ensure SOMETHING is pushed

    ## Relatives by text?
    ## capture image? or image URL?
    ## Pronunciation missing SEE above
    ## modern HOF player inconsistencies and may not all exist
    ### on Durant, need to grab honors 12x all-star, 4x scoring champ, etc
    ### Durant doesnt have all the honors such as most improved and DPOY and 50th or HOF
    ### should mark if player is active as of scraping

    # QUESTION - will @Player variables  

  end

  def display_player_info
    player_info_template = ["player_name", "pronunciation", "full_name", "nickname", "position", "shoots", "height", "weight", "birthdate", "birthplace", "college", "high_school", "college_recruiting_rank", "draft", "nba_debut", "career_length", "experience"]

    @player_info.each_with_index do |pi, i|
      puts player_info_template[i] + " == " + pi
    end
  end

  def get_player_reg_season_total
    @reg_total = @player_page.css("table#totals")
    ## for all tables, import the headers to verify stats line up first between leagues-eras
    # grab career totals to compare for validation?

  end

  def open_link(css_link_class)
    # currently doesn't work
    href = @player_page.css("." + css_link_class).first.children.first['href']
    new_url = URI.join @player_page, href
    @player_playoff_page = open(new_url)
  end

  def get_player_playoff_total
    open_link('.sr_preset')
    @playoff_totals = @player_page.css("table#playoffs_totals")
  end

  def get_player_reg_season_per100
  end

  def get_player_playoff_per100
  end

  def get_player_reg_season_advanced
  end

  def get_player_playoff_advanced
  end

  def get_player_reg_season_adj_shooting
  end

  def get_player_reg_season_playbyplay
  end

  def get_player_playoff_playbyplay
  end

  def get_player_reg_season_shooting
  end

  def get_player_playoff_shooting
  end

end


    # @player_name = @info.at_css("span:nth-child(1)").text
    # @player_name = @info.at_css("span:nth-child(2)").text


    # player_season_table = @doc_season.css("tbody") works on console!!

    ### all messed up.  The commands that work in console not producing the same result.  Go for id = "totals_stats"?

    #trying this sort to get the right table
    # player_season_table = @doc_season.css("table").sort { |x, y| y.css("tr").count <=> x.css("tr").count }.first 
    # puts player_season_table.count
    # rows = player_season_table.css("tr")
    # rows.search('.thead').each(&:remove)  #THIS WORKED
    # puts rows.count
    # puts rows
    # puts rows[0].at_css("td").try(:text) # Gets a single player name

    # console hates attributes
    # puts rows[0].at_css("a").attributes["href"].try(:value) # Gets a single link
    # This method so far just shows the sixers
    # In console shows John Abramovic

    # DONT FORGET LEAGUE AVERAGE HEADER on some pages, but not this one




# THIS WORKED
# rows.search('.thead').each do |row|  
#   row.remove
# end

# these don't work
# rows_sort = rows.select { |row| row.css("tr.thead") }
# rows_sort = rows.reject { |row| row.css("tr.thead") }

# rows_sort = rows.search('.thead').each(&:remove)

# rows_sort = rows.select { |row| row.search("thead") }   #works to create new of 
# rows[23].at_css("td:nth-child(3)".try(:text))
# rows[23].at_css("th").try(:text) yielded "Rk"