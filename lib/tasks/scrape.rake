# 1. We scrape index pages to get the pages we need to scrape movies of
# 2. We scrape all movie links
# 3. We scrape all reviews
# 4. We update publication names to movie review


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

  desc "Scrapes only the latest reviews not in db"
  task recent: :environment do
  	rake_support = RakeSupport.new
    rake_support.scrape_recent
  end
end

namespace :update do 

  desc "Adds critic and publication names to movie review"
  task :reviews => :environment do 
    rake_support = RakeSupport.new
    rake_support.update_reviews_with_names
  end
end