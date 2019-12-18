# Project4 Part2 DOS Fall 2019
## Twitter Simulator

# Team Members
Tianyang Chen 49252917, Ju Cai 96691796

# Abstract
In this part ,we implement a web interface for the simulator we created project 4.1, using phoenix that 
allows access to the ongoing simulation using a web browser. 

The main functions including:
1. Register account
2. Send tweet. Tweets can have hashtags (e.g. #COP5615isgreat) and mentions (@bestuser)
3. Subscribe to user's tweets
4. Re-tweets (so that your subscribers get an interesting tweet you got by other means)
5. Allow querying tweets subscribed to, tweets with specific hashtags, tweets in which the user is mentioned (my mentions)
6. If the user is connected, deliver the above types of tweets live (without querying)

# Runtime Commands
1. Extract the contents of the zip file.
2. And CD into the inner folder `proj4p2`
3. To start your Phoenix server:
     * Install dependencies with `mix deps.get`
     * Create and migrate your database with `mix ecto.setup`
     * Install Node.js dependencies with `cd assets && npm install`
     * Start Phoenix endpoint with `mix phx.server`
3. Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

# Functionalities
1. Register
We can use the Register fuction to create the user information and store in the server.
2. Tweet
We use the Tweet function to create random tweet message. The tweet have a chance of producing a common tweet message, or tweet with hashtag, or the tweet with the mention. And show in the terminal.
3. Retweet
In the function, the users have the chance of retweeting the message from the users which they subscribe.
4. Querying
In the function, we can query the tweet of every type.
5. Subscribe
In this part, we get random number of subscriber for each user and store the information in the server.
6. Deliver the tweets alive 
7. Login/out
In the function, we control the thread state of connection of disconnection.

