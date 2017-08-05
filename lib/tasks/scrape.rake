namespace :scrape do
  desc "Scrapes all from zero"
  task all: :environment do
  	puts 'snarffff'
  end

  desc "Scrapes only the latest reviews not in db"
  task update: :environment do
  	puts "farttt buttz"
  end

end
