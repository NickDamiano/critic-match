# require '/scraper.rb'

namespace :scrape do
  desc "Scrapes all from zero"
  task :all => :environment do

  	index_pages = []
  	scraper = MetacriticScraper.new 
  	# # A-Z Scraper - Load the first # page then loop through a-z
  	index_pages.push(scraper.scrape_for_index('#'))
  	# alphabet = ("a".."b").to_a
  	# alphabet.each do |letter|
  	# 	result = scraper.scrape_for_index(letter)
  	# 	p "LETTER #{letter} RESULT BELOW!!!!!!!!"
  	# 	index_pages.push(result)
  	# 	sleep(5)
  	# end
  	index_pages.flatten!

  	# Movie Links scraper
  	movies_pages = []
  	index_pages.each do | index_page |
  		result = scraper.scrape_for_movies(index_page)
  		movies_pages += result
  		p "CURRENT INDEX PAGE IS #{index_page}"
  		sleep(rand(2..3))
  	end

  	# Reviews Links Scraper
  	reviews = []
    saver = Saver.new
    # movies_pages = saver.get_movie_uris
  	movies_pages.each do | movie_page |
      p "ABOUT TO SCRAPE #{movie_page}"
  		result = scraper.scrape_reviews("http://www.metacritic.com#{movie_page}")
      # the above takes back all reviews for one movie. so we should be able to 
        # grab the first review, get the movie information, and save it to the database
      first = result.first 
      if first.nil?
        binding.pry 
        p 'uh oh spaghetti-os'
      end
      movie = saver.save_movie(first)
      result.each do | review | 
        critic = saver.save_critic(review)
        review = saver.save_review(review, movie, critic)
      end
        # iterate through each review, save critic if not already in the database and if in database, get id for critic
        # save the actual review into the database with movie_id and critic_id
  		reviews.push(result)
  	end
    # call review saver. 
    # save movie if not in database
    # save critic if not in database
    # save review if not in database
    # should save the movie into the database and return AR object with id - call save movie
    # then when the critic info is collected below, it should save the critic if they don't exist call save critic
    # then it should create the review (movie_critics) with both ids associated and call save review
  end








  desc "Scrapes only the latest reviews not in db"
  task update: :environment do
  	puts "farttt buttz"
  end

  desc "rails magic needed"
  task test: :environment do 
    movie_info = {:score=>"100",
    :author_name=>"Joe Walsh",
    :author_uri=>"/critic/joe-walsh?filter=movies",
    :publication_name=>"CineVue",
    :publication_uri=>"/publication/cinevue?filter=movies",
    :movie_title=>"12 Years a Slave",
    :image_thumbnail=>
     "http://static.metacritic.com/images/products/movies/2/3910c2e8cfefeb21fcd6079451336f86-98.jpg",
    :release_date=>"October 18, 2013",
    :movie_uri=>"http://www.metacritic.com/movie/12-years-a-slave",
    :metacritic_score=>"96"}

    saver = Saver.new
    saver.save_movie(movie_info)
    end
end

require 'mechanize'
require 'pry-byebug'


# TODO for Sunday -
#scrapers
#  create rake tasks to scrape all, scrape letter range
#  create method/class that can scrape http://www.metacritic.com/browse/movies/release-date/theaters/date
#  create daily cron job to look for new movies in rss feed (XML) maybe using just a api request thing
#  write tests for scrapers and use vcr gem
#modify models for columns for review_uri and critic_uri etc also add image thumbnails
#scrape the reviews (make sure no additions needed for models
#  setup api for ajax return for queries on movie
#start frontend
# create title thing, initially log results in console
# build css for movie element and have the page display approipriate number based on width
# after you click on each element for the review have it reload with the appropriate number (checking
	#media query again each time in case of resize or phone turn)
# set up local storage logging for user reviews
# when user clicks, ajax fires, gets all reviews as api, then javascript loops through each review, 
# calculates point difference for that critic, updates local storage by critic id with point differential
# and increments number of matched review and adds a percentage match field
# log the top 3 with name, percentage, and count of reviews (skews towards an inactive critic who you match with a lot)
# maybe we need a minimum match
# do CSS styling for matching bars
#stretch goals!
# create critic page where it shows which movies, your score, their score, differential (but i need to store that)
# create authentication
# create ability to type in number 1-100
# TESTS!
