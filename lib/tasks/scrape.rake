namespace :scrape do


  desc "Scrapes all index pages into a yaml file index_pages.yml"
  task :index => :environment do 
    rake_support = RakeSupport.new
    rake_support.scrape_all_indices
  end

  desc "Scrapes all movie links"
  task :movie_links => :environment do 
    rake_support = RakeSupport.new 
    rake_support.scrape_all_movies
  end

  desc "Scrapes all reviews"
  task :reviews => :environment do 
    rake_support = RakeSupport.new
    rake_support.scrape_all_reviews
  end

  desc "Scrapes all from zero"
  task :all => :environment do
  
    # instantiate RakeSupport
    # call scrape all indices
    # call scrape all movies
    # call scrape all reviews
  end

  desc "Scrapes only the latest reviews not in db"
  task update: :environment do
  	puts "farttt buttz"
  end
end


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
