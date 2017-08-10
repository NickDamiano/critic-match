require 'test_helper'
require 'vcr'

VCR.configure do |config|
	config.cassette_library_dir = "fixtures/vcr_cassettes"
	config.hook_into :webmock # or :fakeweb
end

class ScraperTest < ActiveSupport::TestCase

  test 'should scrape an index page to get all pages for that letter' do 
  	scraper = MetacriticScraper.new
  	VCR.use_cassette("letter_b") do 
  		result = scraper.scrape_for_index("b")
  		expected = "http://www.metacritic.com/browse/movies/title/dvd/b"
  		expected_last = "http://www.metacritic.com/browse/movies/title/dvd/b?page=5"
  		assert_equal expected, result[0]
  		assert_equal expected_last, result[-1]
  	end
  end

  test 'should scrape a list of movie links from an index page' do 
  	scraper = MetacriticScraper.new
  	VCR.use_cassette("movie_list_b2") do 
  		uri = "http://www.metacritic.com/browse/movies/title/dvd/b?page=1"
  		result = scraper.scrape_for_movies(uri)
  		first = "/movie/batman-v-superman-dawn-of-justice"
  		assert_equal 95, result.count 
  		assert_equal first, result[0]
  	end
  end

  test 'should scrape the reviews from a movie page' do 
  	
  end
end
