require 'yaml'
require './metacritic_scraper.rb'

class Fart 
	def do_shit 
		scraper = MetacriticScraper.new
		result = scraper.scrape_for_index("a")
		p "result is #{result}"
		save_yaml(result)
	end

	def save_yaml(data)
		File.open("test.yml","w+") do |f|
			f.write(data.to_yaml)
		end
	end
end

fart = Fart.new
fart.do_shit