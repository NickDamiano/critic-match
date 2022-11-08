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
      binding.pry
  		first = "/movie/batman-v-superman-dawn-of-justice"
  		assert_equal 95, result.count 
  		assert_equal first, result[0]
  	end
  end

  test 'should scrape the reviews from a movie page' do 
  	uri = "http://www.metacritic.com/movie/roll-bounce"
  	scraper = MetacriticScraper.new
  	VCR.use_cassette("roll-bounce") do 
  		result = scraper.scrape_one_movies_reviews(uri)
  		first = result.first 
  		assert_equal 27, result.count
  		assert_equal "Owen Gleiberman", first[:author_name]
  		assert_equal "/critic/owen-gleiberman?filter=movies", first[:author_uri]
  		assert_equal "Entertainment Weekly", first[:publication_name]
  		assert_equal "/publication/entertainment-weekly?filter=movies", first[:publication_uri]
  		assert_equal "Roll Bounce", first[:movie_title]
  		assert_equal "http://static.metacritic.com/images/products/movies/3/e8a5b2366b4572fd3cf7db7ab6bb6875-98.jpg", first[:image_thumbnail]
  		assert_equal "September 23, 2005", first[:release_date]
  		assert_equal "http://www.metacritic.com/movie/roll-bounce", first[:movie_uri]
  		assert_equal "59", first[:metacritic_score]
  		assert_equal "83", first[:score]
  	end
  end

  test 'should return nil if scrape is nil or empty array' do 
  	uri = "http://www.metacritic.com/movie/oh-boy"
  	scraper = MetacriticScraper.new
  	VCR.use_cassette("oh-boy") do 
  		result = scraper.scrape_one_movies_reviews(uri)
  		assert_nil result
  	end
  end

  test 'should scrape recent movies and return a list of movie links' do 
  	scraper = MetacriticScraper.new
  	VCR.use_cassette("recent-movies") do 
  		result = scraper.scrape_recent_movies
  		first_movie_uri = result.first.attributes["href"].value
  		assert_equal 135, result.count
  		assert_equal "/movie/the-dark-tower", first_movie_uri
  	end
  end
end
