

	// *********************************** Variables ************************************
	var all_movies;
	var active_movies;
	var critics_reviews;
	var reviews_active;
	var array_of_movie_ids =[];
	var match;

	// *********************************** Functions ************************************

	// *********************************** Get Session Variables section ************************************

	

	// sets variable which is iterated on each time a movie is reviewed
	function getMatch(){
		if(sessionStorage["match"] == undefined ){
			sessionStorage.setItem('match', JSON.stringify(0));			
		}
		match = JSON.parse(sessionStorage['match']);
	}

	// Sets an empty object in session storage if this is the first time they visit the site
	function getTopMatch(){
		if(sessionStorage["topMatch"] == undefined ){
			top_match = [{critic_id: 0, percentage: 0, matches: 0}, {critic_id: 0, percentage: 0, matches: 0}, {critic_id: 0, percentage: 0, matches: 0}];
			sessionStorage.setItem('topMatch', JSON.stringify(top_match));	
		}
		top_match = JSON.parse(sessionStorage['topMatch']);
		if(top_match[0]["percentage"] > 0){
			top_match.reverse();
			updateTopMatch(top_match);
		}
	}

	// sets or pulls critic_reviews object
	function getCriticsReviews(){
		if(sessionStorage["criticsReviews"] == undefined ){
			critics_reviews = {};
			sessionStorage.setItem('criticsReviews', JSON.stringify(critics_reviews));			
		}
		critics_reviews = JSON.parse(sessionStorage['criticsReviews']);
	}

	// Sets an empty object in session storage if this is the first time they visit the site for user review records
	function getUserReviews(){
		if(sessionStorage["userReviews"] == undefined ){
			user_reviews = {};
			sessionStorage.setItem('userReviews', JSON.stringify(user_reviews));			
		}
		user_reviews = JSON.parse(sessionStorage['userReviews']);
	}

	// ******************************************************* Update Functions Section ****************************************

	// updates user review object after each rating is made
	function updateUserReviews(review){
		var rating = review[0];
		var movie = review[1];
		user_reviews[movie] = rating;
		sessionStorage.setItem('userReviews', JSON.stringify(user_reviews));
	}

	// run initially and when top critic match is identified in updateCriticResults. Updates HTML for top match
	function updateTopMatch(top_match){
		top_match.reverse();
		for(var i=0; i<3; i++){
			var top_match_html = document.querySelector("#top_match_" + (i+1));
			percentage = top_match[i]["percentage"];
			matches = top_match[i]["matches"];
			critic_id = top_match[i]["critic_id"];
			critic_name = top_match[i]["name"]
			critic_publication = top_match[i]["publication"]
			// add some sort of clarification here so they understand the match rate
			top_match_html.innerHTML = "<a href='/critic/" + critic_id + "'" + ">" + critic_name  + " - " + percentage + "%" + " for " + matches + ' matches'  + " - " + critic_publication + "</a>";
			percentage = percentage - 16.7 + '%';
			if ( $(window).width() > 480) {      
				document.getElementById("top_match_" + (i+1)).style.width= percentage;
				continue;
			}
  			document.getElementById("top_match_" + (i+1)).style.width= "100%";
		}		
	}

	//Updates critic object upon each click of a rating
	function updateCriticResults(movie_and_rating){
		//convert to 0-100 to match up with critic reviews
		var total_matches;
		var total_points;
		var percentage;
		var rating 	= (movie_and_rating[0] * 25) - 10;
		var movie_id 	= movie_and_rating[1];
		var reviews = reviews_active[movie_id];
		for(var i=0; i < reviews.length; i++){
			var critic 				= reviews[i]["critic_id"];
			var name 				= reviews[i]["critic_first_name"] + " " + reviews[i]["critic_last_name"]
			var publication 		= reviews[i]["publication"]
			var score 				= reviews[i]["score"];
			var difference 			= Math.abs(rating - score);
			// if critic exists do this
			if(critic in critics_reviews){
				critics_reviews[critic]["matches"] += 1;
				critics_reviews[critic]["points"] += difference;
				total_matches 	= critics_reviews[critic]["matches"];
				total_points 	= critics_reviews[critic]["points"];
				critics_reviews[critic]["percentage"] = Math.round(100 - (total_points / total_matches));
				percentage = critics_reviews[critic]["percentage"];
                critics_reviews[critic]["movies"].push([movie_id, score]);
			}else if(!(critic in critics_reviews)){
				critics_reviews[critic] = {
					"matches": 1,
					"points" : difference,
					"percentage": (100-difference),
					"name": name,
					"publication": publication,
                    "movies": [[movie_id, score]]
				}
			}
			//if critic does not exist in database do this check against top match and replace top match if score is higher
			// TODO extract this to its own method where we have a top 3 array and each is compared. 
			//critic is the id of the critic and the key for the critic match
			compareCriticsForTopMatch(critic);
			sessionStorage.setItem('criticsReviews', JSON.stringify(critics_reviews));

		}
	}

	//Check critic result against top_match
	// if top_match[j] is the same critic as being evalued against, replace top_match[j] and break the loop
	// if top_match[j] is barely matching, delete them
	// else if top_match[j] meets the requirements for being a top match, set them to that critic
	function compareCriticsForTopMatch(critic){
		
		// First we loop through the top match and update the top_match with the critic if they match
		for(var i=0; i<3; i++){
			if(top_match[i]["critic_id"] == critic ){
				// update the current critic with the most current match information
				top_match[i] = critics_reviews[critic]
				// set the id property to the current critic
				top_match[i]["critic_id"] = critic;
				// sort the matches
				result = sortTopMatch(top_match);
				// update the top match html
				updateTopMatch(result);
				// save the matches into sessionstorage in case page is refreshed we can retrieve and display it 
				sessionStorage.setItem('topMatch', JSON.stringify(top_match));
				critic = false;
				// break the loop so we don't compare the same critic to any other of the top matches and have duplicates
				return;
				// if the current top match critic id is not the id of the one passed in, and the one passed in's percentage is higher than current one, and 
				// the matches for this critic passed in is 50% of the current one so not some dude with 1 review
			}
		}
		// if the critic matched in the above then we don't want them anymore
		for(var j=0; j<3;j++){
			// set variable for matches for the current critic 
      		var matches = top_match[j]["matches"];
      		// if the id of the current critic matches the id of the one passed in
      		if( matches < (Object.keys(user_reviews).length / 4)){
				top_match[j] = {critic_id: 0, percentage: 0, matches: 0};
				sessionStorage.setItem('topMatch', JSON.stringify(top_match));
			}
			if(critics_reviews[critic]["percentage"] > top_match[j]["percentage"] && critics_reviews[critic]["matches"] > ( matches / 2)) {
				// replace current top match with passed in critic
				top_match[j] = critics_reviews[critic];
				// update current top match critic object with critic id passed in
				top_match[j]["critic_id"] = critic;
				// store result of sorting top matches
				result = sortTopMatch(top_match);
				// update top match in html
				updateTopMatch(result);
				// store top match 
				sessionStorage.setItem('topMatch', JSON.stringify(result));
				// break so we don't compare this passed in critic with anyone else
				break;
			}
		}
	}

	// sort top_critic 
	function sortTopMatch(top_match){
		// sorting below
		top_match = top_match.sort(function(a, b) {
			return parseFloat(a.percentage) - parseFloat(b.percentage);
		})
		return top_match;
	}

	//Update DOM with active movies
	function updateDomWithMovies(){
		var movies_html_id = document.querySelector("#movies");
        // Todo Swap out the movie_element foreach with regular array or each
        // because it's breaking precompile
        for(var k=0;k < active_movies.length; k++){
            movie = active_movies[k];
			var movie_element = document.createElement('div');
			movie_element.className = 'movie';
			var movieTitle 	= document.createElement('div');
			movieTitle.className = 'movie_title';
			var image 	= document.createElement('img');
			var buttons = document.createElement('div');
			buttons.addClass = 'buttons';
			$(buttons).attr('id', movie.id);
			for(var i=1; i < 5; i++){
				var button = document.createElement('button');
				button.className = 'button_' + movie.id + ' btn btn-default';
				button.addEventListener('click', function() { 
					var movie_and_rating = [];
					match++;
					this.className = 'clicked btn btn-primary';
					this.disabled = true;
					sessionStorage.setItem('match', JSON.stringify(match));
					movie_and_rating.push(this.innerHTML);
					movie_and_rating.push(this.parentNode.id);
					// disable the buttons
                    var movie_id = this.parentElement.id
					buttons_to_be_disabled = document.querySelectorAll(".button_" + movie_id);
					disableButtons(".button_" + movie_id);
					checkIfAllReviewed();
					updateCriticResults(movie_and_rating);
					updateUserReviews(movie_and_rating);
					// call function to update critic object
				})
				button.innerHTML = i;
				buttons.appendChild(button);
			}
			var havent_seen_button = document.createElement('button');
			havent_seen_button.className = 'button_' + movie.id + ' btn btn-default havent_seen';
			havent_seen_button.innerHTML = "Have not seen";
			havent_seen_button.addEventListener('click', function() { 
					//TODO pass [-1,movie_id] to updateUserReviews
					this.className = 'clicked btn btn-primary havent_seen';
					this.disabled = true;
                    var movie_id = this.parentElement.id
					disableButtons('.button_' + movie_id);
					checkIfAllReviewed();
				})
			buttons.appendChild(havent_seen_button);
			image.src = movie.image_uri;
			image.style.height = '143px';
			image.style.width = '98px';
			movieTitle.innerHTML = movie.title;
			movie_element.appendChild(movieTitle);
			movie_element.appendChild(image);
			// TODO fix this with controller specific js
			movie_element.appendChild(buttons);
			if(movies_html_id){
				movies_html_id.appendChild(movie_element)
			}
		}
	}


	// ******************************************* API Calls ******************************************

	//Gets all matching movies as a follow up to draw from for reviews
	function getAllMoviesApi()  {
		if(all_movies.length == 0){
			return $.ajax({
				dataType: 'json',
				url: '/api/movies',
				success: function(data) {
					all_movies = data;	
					sessionStorage.setItem('all_movies', JSON.stringify(all_movies));
					// delete the active movies from it			
				}						
			})	
		}
		
	}

	//Gets the reviews for the active movies being rated by the user
	function getActiveReviews() {
		var movie_ids = array_of_movie_ids
		return $.ajax({
			datatype: 'json',
			url: '/api/reviews/' + movie_ids,
			success: function(data) {
				reviews_active = data;
			}
		})
		return reviews_active;
	}

	//Gets initial 5 movies to load onto landing page
	function getFirstMovies()  {
		if( typeof all_movies == 'undefined'){
			all_movies_check = sessionStorage['all_movies']
			all_movies = (typeof all_movies_check == 'string' ) ? JSON.parse(all_movies_check) : [] ;	
		}
		if(all_movies.length > 0){
			active_movies = all_movies.splice(0,4);
			sessionStorage.setItem('all_movies', JSON.stringify(all_movies));
			return Promise.resolve(true);
		}else if (all_movies.length == 0){
			return $.ajax({
				dataType: 'json',
				url: '/api/movies/first-movies',
				success: function(data) {
					active_movies = data;				
				}						
			})
		}
	}

    function getMovieBatch(movie_ids) {
        return $.ajax({
            datatype: 'json',
            url: '/api/movies/' + movie_ids,
            success: function(data) {
                movies = data;
            }
        })
        return JSON.parse(movies);
    }

	// *********************************************** Helper Functions *******************************************

	// Sets the variable for array of movies in preparation for getting the reviews for active
	function setMovieIdArray(){
		array_of_movie_ids = []
		for(var count = 0; count < active_movies.length; count++){
			array_of_movie_ids.push(active_movies[count].id)
		}
		return array_of_movie_ids;
	}

	
	// Refreshes movies after all have been selected
	//////////////////////////////////////////////////////////////////
	function loadNextMovies(){
		getFirstMovies();
		var movie_element = document.getElementById('movies');
		while(movie_element.firstChild){
			movie_element.removeChild(movie_element.firstChild);
		}
		updateDomWithMovies();
		setMovieIdArray();
		getActiveReviews()
		.then(reorganizeReviews);
	}

	// Reorganizes reviews to be easily called by id number
	function reorganizeReviews(){
		var active_reviews = {};
		for(var i=0; i < reviews_active.length; i++){
			id = reviews_active[i][i].movie_id + ''
			active_reviews[id] = reviews_active[i]
		}
		reviews_active = active_reviews;
	}

	// Checks if all reviews have been clicked and calls load next movie if they have
	function checkIfAllReviewed(){
		var buttons = document.querySelectorAll('button');
		var buttons_flag = true
		for(var i = 0; i < buttons.length; i++){
			if(buttons[i].disabled == false){
				buttons_flag = false
				break;
			}
		}
		if( buttons_flag == true ){
			loadNextMovies();
		}
	}

	// Disables buttons - Called each time a review is made
	function disableButtons(button_class){
		buttons_array = document.querySelectorAll(button_class);
		for(var i = 0; i < buttons_array.length; i++){
			buttons_array[i].disabled = true;
		}
	}

	// Because we get two random sets of movies for active api and all api, we delete the active movies from all
	// Need to iterate down because index resets after deleting 
	function deleteActiveMoviesFromAll(){
		var movie_ids = Object.keys(reviews_active)
		for(var i=0;i<all_movies.length;i++){
			if(	all_movies[i].id == movie_ids[0] ||
				all_movies[i].id == movie_ids[1] ||
				all_movies[i].id == movie_ids[2] ||
				all_movies[i].id == movie_ids[3] ||
				all_movies[i].id == movie_ids[4] ||
				all_movies[i].id == movie_ids[5] ){
				all_movies.splice(i,1);
				i--;
			}
		}
	}

    // ******************************************** Critic **************************************************

    function criticPage(){
        var url = document.URL.split('/')
        if(url.length == 5){
            // run critic page javascript
            var critic_id = Number(url[4])
            console.log(critic_id)
            var critics_reviews = JSON.parse(sessionStorage['criticsReviews']);
            var criticReviews = critics_reviews[critic_id].movies;
            var user_reviews = JSON.parse(sessionStorage['userReviews']);
            // so then it loops through criticReviews, gets the id and score,
            // then calls users review by id and converts the score to 0-100
            // then calls a method which creates an html element and attaches it
            // then does the next one
            var movies_array = [];
            for(var i=0;i<criticReviews.length;i++){
                movies_array.push(criticReviews[i][0])
            }
            var movies = getMovieBatch(movies_array);
            console.log(movies);
            for(var i=0;i<criticReviews.length;i++){
                var movie_id = criticReviews[i][0];
                var critic_score = criticReviews[i][1];
                var user_review = user_reviews[movie_id] * 25 - 10
                var movie_element = document.createElement('div');
                // set inner html to title.
                // create element for critic score put his name and score
                // create element for user
                // add these to movie_element, then do it again, scores should float
                // tricky part is the name so it doesn't overrun

                console.log(movie_id);
                console.log(critic_score);
                console.log(user_review);
            }
            console.log(criticReviews);
            console.log(user_reviews);
        }
    }
 

	// ******************************************** Main **************************************************
	$( document).ready( main );
    $( document ).ready(criticPage);

	function main(){
		var movie_element = document.getElementById('movies');
		// TODO fix this with controller specific js
		if(movie_element){
			movie_element.removeChild(movie_element.firstChild);
		}
		// here get the width with a mediaquery and put that in a variable and then call number of movies for that width below
		getFirstMovies()
		.then(getTopMatch)
		.then(getCriticsReviews)
		.then(getUserReviews)
		.then(updateDomWithMovies)
		.then(setMovieIdArray)
		.then(getActiveReviews)
		.then(reorganizeReviews)
		.then(getMatch)
		.then(getAllMoviesApi)
		.then(deleteActiveMoviesFromAll)
	}