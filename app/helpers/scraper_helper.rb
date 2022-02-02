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
    # p league_year
  end

  def players_total_of_season(year, league = 'NBA')
    #always the latter year of the season, first year is 1947
    league_year = league_year_prefix(year, league)
    season = target_scrape("basketball-reference.com/leagues/#{league_year}_totals.html")
  end

  def players_advanced_of_season(year, league = 'NBA')
    #always the latter year of the season, first year is 1947
    league_year = league_year_prefix(year, league)
    season = target_scrape("basketball-reference.com/leagues/#{league_year}_advanced.html")
  end

  def players_adj_shooting_of_season(year, league = 'NBA')
    #always the latter year of the season, first year is 1947
    league_year = league_year_prefix(year, league)
    season = target_scrape("basketball-reference.com/leagues/#{league_year}_adj_shooting.html")
  end

end