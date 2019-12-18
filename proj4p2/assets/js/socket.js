// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
socket.connect()


// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("room:lobby", {})



//Welcolm or logOut
let initialString = document.querySelector("#welcome")
let logOutButton = document.querySelector("#logOut")

// register_client
let usernameInput = document.querySelector("#username")
let loginButton = document.querySelector("#login")
let title = document.querySelector("#title")
title.innerHTML = "Welcome to Tweeter World"

//send_tweet
let tweetInput = document.querySelector("#tweet")
let sendButton = document.querySelector("#send")

//tweet_list
let allTweetList = document.getElementById("allTweet");

let hashtagString1 = document.getElementById("hashtag");
let mentionString1 = document.getElementById("mention");



logOutButton.addEventListener("click", event => {

	title.innerHTML = "Welcome to Tweeter World"

	initialString.style.display = "block"
	logOutButton.style.display = "none"

	usernameInput.value = ""
	usernameInput.style.display = "block"
	loginButton.style.display = "block"

	tweetInput.style.display = "none"
	tweetControl.style.display = "none"

})

loginButton.addEventListener("click", event => {
	if(usernameInput.value != ""){
		channel.push("connect_boss",{client_id: usernameInput.value})
		title.innerHTML = "Let's tweet your stories," + usernameInput.value + "!"

		logOutButton.style.display = "block"
		initialString.style.display = "none"

		usernameInput.style.display = "none"
		loginButton.style.display = "none"

		tweetInput.style.display = "block"
		tweetControl.style.display = "block"


	}
})




sendButton.addEventListener("click", event => {
	if(tweetInput.value != ""){
		channel.push("send",{tweet: tweetInput.value, client_id: usernameInput.value, retweet: false, hashtag: hashtagString1.value, mention: mentionString1.value})

		tweetInput.value = ""
	}
})



channel.on('send',  payload => {

	let li = document.createElement("li"); // create new list item DOM element
	let client_id = payload.client_id;    // get name from payload or set default
	let tweet = payload.tweet
	li.innerHTML = '<b>' + client_id + '</b>: ' + tweet
	let button = document.createElement("button");
	button.innerHTML = "Retweet";
	li.appendChild(button)                  // append to list
	button.addEventListener("click", event => {
		channel.push("send",{tweet: tweet, client_id: client_id, retweet: true, hashtag: "", mention: ""})
	})


	allTweetList.append(li);
});


channel.on('tweet',  payload => {
	let li = document.createElement("li"); // create new list item DOM element
	// let name = payload.tweet;    // get name from payload or set default

	let client_id = payload.tweet.split(":")[0]
	let tweet = payload.tweet.split(":")[1]

	if(tweet == " hashtag"||tweet == " mention"){
		li.innerHTML = '<b>' + client_id
	}else if(tweet == " get user"){
		li.innerHTML = '<b>' + client_id
		if(usernameInput.value != client_id){
			let sub = document.createElement("button");
			sub.innerHTML = "Subscribe";
			li.appendChild(sub)                  // append to list
			sub.addEventListener("click", event => {
				channel.push("subscribe",{target_id: client_id, client_id: usernameInput.value})
			})
		}
	}else{
		li.innerHTML = '<b>' + client_id + '</b>: ' + tweet
		let button = document.createElement("button");
		button.innerHTML = "Retweet";
		li.appendChild(button)
		// var button = document.createElement("button");
		// let button = document.getElementById(tweet);
		// console.log(document.getElementById(tweet))
		button.addEventListener("click", event => {
			channel.push("send",{tweet: tweet, client_id: client_id, retweet: true, hashtag:"", mention: ""})
		})

	}



	// var button = document.createElement("button");
	// let button = document.getElementById(tweet);
	// console.log(document.getElementById(tweet))



	allTweetList.appendChild(li);                    // append to list
});




//subscribe
let userListTweetsButton = document.getElementById("userlist");
let mentonListTweetsButton = document.getElementById("mentionList");
let HashtagListTweetsButton = document.getElementById("HashtagList");
let queryByUser = document.getElementById("queryAllMyTweets");
let queryBySubscribeButton = document.getElementById("queryBySubscribe");
let queryByMentionButton = document.getElementById("queryByMention");
let queryByHashtagButton = document.getElementById("queryByHashtag");

let hashtagString = document.getElementById("hashtag2");
let mentionString = document.getElementById("mention2");

queryByUser.addEventListener("click", event => {
	while(allTweetList.firstChild) allTweetList.removeChild(allTweetList.firstChild);
	channel.push("query_all_my_tweets",{client_id: usernameInput.value})
})

userListTweetsButton.addEventListener("click", event => {
	while(allTweetList.firstChild) allTweetList.removeChild(allTweetList.firstChild);
	channel.push("get_list",{client_id: usernameInput.value})
})
mentonListTweetsButton.addEventListener("click", event => {
	while(allTweetList.firstChild) allTweetList.removeChild(allTweetList.firstChild);
	channel.push("get_mentionlist",{client_id: usernameInput.value})
})
HashtagListTweetsButton.addEventListener("click", event => {
	while(allTweetList.firstChild) allTweetList.removeChild(allTweetList.firstChild);
	channel.push("get_hashtaglist",{client_id: usernameInput.value})
})

queryBySubscribeButton.addEventListener("click", event => {
	while(allTweetList.firstChild) allTweetList.removeChild(allTweetList.firstChild);
	channel.push("subscribe_query",{client_id: usernameInput.value})
})

queryByMentionButton.addEventListener("click", event => {
	while(allTweetList.firstChild) allTweetList.removeChild(allTweetList.firstChild);
	channel.push("mention_query",{client_id: usernameInput.value,mention: mentionString.value})
})

queryByHashtagButton.addEventListener("click", event => {
	while(allTweetList.firstChild) allTweetList.removeChild(allTweetList.firstChild);
	channel.push("hashtag_query",{client_id: usernameInput.value, hashtag: hashtagString.value})
	hashtagString.value = ""
})

// simulate
let simulateButton = document.querySelector("#simulate")
simulateButton.addEventListener("click", event => {
	channel.push("simulate",{client_id: usernameInput.value})
})


channel.join()
//   .receive("ok", resp => { console.log("Joined successfully", resp);usernameInput.value = "sishun"
// loginButton.click();})
	.receive("ok", resp => { console.log("Joined successfully", resp)})
	.receive("error", resp => { console.log("Unable to join", resp) })

export default socket