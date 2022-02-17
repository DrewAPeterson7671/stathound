#!/usr/bin/ruby

require ('../app/helpers/scraper_helper')
require 'pry-rails'
require 'watir'
require 'nokogiri'

# ScraperHelper.players_total_of_season(1947)
league_year = "BAA_1947" #argument bridge
url = "basketball-reference.com/leagues/#{league_year}_totals.html" #argument bridge


# target_scrape
browser = Watir::Browser.new(:chrome)
browser.goto(url)
doc = Nokogiri::HTML.parse(browser.html)


@doc_season = doc #argument bridge


# gather_players_from_season
player_season_table = @doc_season.css("tbody")
rows = player_season_table.css("tr")
rows.search('.thead').each(&:remove) #THIS WORKED
rows[0].at_css("td").try(:text) # Gets player name
rows[0].at_css("a").attributes["href"].try(:value)

