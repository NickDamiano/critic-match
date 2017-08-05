# all 
# get http://www.metacritic.com/browse/movies/title/dvd
# loop through all titles and get the url
# under class pages, see how many pages
# the format is http://www.metacritic.com/browse/movies/title/dvd?page=1 and movies/title/dvda?page=1 for letter a 
#TODO if release date is less than 3 months, cron job looks for new reviews
#TODO add a model for websites with columns of movie page, index page ?
#TODO for the movies that the user gets, have it start with maybe a month old release dates 
#TODO have it ask click the genres you don't watch 
#TODO add genre column to movie table
# so it gets the a b c d page and goes through all the links
# STRETCH GOAL possibly cult classic thing where you can search for the movie, and put your review in so there's a movie you love that
# you know most people hate and you can search through it. 
# SO it gets all links to all index pages first 
# then it goes through all index pages one at a time and gets the movie pages
# then 
#TODO add string column to movies for url so you can go to the url to scrape it
#Possibly have it where the critics that are closest matches after 10 movies, you pull movies in reverse order from what
# they have reviewed. probably a TODO for optimization and tweaking of algorithm on how movie titles are served
# some more statistics - get average number of reviews and figure out a cut off so if a movie is like 10 reviews or less,
# skip it.


# Phase 1 get all index pages
# Phase 2 get all movie pages
# Phase 3 get all reviews and save them with critic, publication, score into the database

class IndexScraper

	def scrape_indices(letter)
		# goes to http://www.metacritic.com/browse/movies/title/dvd/#{letter}
		# returns numbers of pages li links
	end
	# movie name has hyphenated spaces and punctuation like periods and spaces are stripped - also note
	#   that index page is 0 index so page 1 doesn't have anything, page 2 is page 1
	def scrape_movie_links(index_page)
		# scrapes all links from a index page and returns them in an array
	end

	# movie link is url for movie page that has all reviews - http://www.metacritic.com/movie/rocky/critic-reviews
	#   if the movie is a remake it will have the year so robocop-2013
	def scrape_reviews(movie_link)
		# under class critic_reviews you have url for critics' page, the url for publications page, class metascore_w for 
		#    the actual score
	end
end