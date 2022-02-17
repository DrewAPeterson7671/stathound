module ScraperHelper
  
  def test_test(name)
    "Hello #{name}!"
  end

  def target_scrape(url)
    browser = Watir::Browser.new(:chrome)
    browser.goto(url)
    doc = Nokogiri::HTML.parse(browser.html)
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

  def gather_players_from_season
    player_season_table = @doc_season.css("tbody") works on console!!
    rows = player_season_table.css("tr")
    rows.search('.thead').each(&:remove)
    puts rows[0].at_css("td").try(:text)
    puts rows[0].at_css("a").attributes["href"].try(:value)
  end
  
end

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