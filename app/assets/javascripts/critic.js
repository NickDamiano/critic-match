// sets or pulls critic_reviews object
var critics_reviews
function getCriticsReviews(){
	if(sessionStorage["criticsReviews"] == undefined ){
		critics_reviews = {};
		sessionStorage.setItem('criticsReviews', JSON.stringify(critics_reviews));			
	}
	critics_reviews = JSON.parse(sessionStorage['criticsReviews']);
	return critics_reviews
}

function criticMain(){
	var page = window.location.href;
	var critic_id = page.split('/')[4];
	var critic = critics_reviews[critic_id].name
	document.getElementById('critic-name').innerHTML = critic
}

$( document).ready( getCriticsReviews );
$( document).ready( criticMain );