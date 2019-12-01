# Project4 Part1 DOS Fall 2019
## Twitter Simulator

# Team Members
Tianyang Chen 49252917, Ju Cai 96691796

# Abstract
In the project, we need to implement a Twitter simulator that we have a server which is the centre of the system. We store the users information including account and password and twitter message in the server using ETS(Erlang Term Storage). And the server contains all the functions including tweet, retweet, getting hastags and mentions. And we can have serval clients for the server. 
The main functions including:
1. Register account
2. Send tweet. Tweets can have hashtags (e.g. #COP5615isgreat) and mentions (@bestuser)
3. Subscribe to user's tweets
4. Re-tweets (so that your subscribers get an interesting tweet you got by other means)
5. Allow querying tweets subscribed to, tweets with specific hashtags, tweets in which the user is mentioned (my mentions)
6. If the user is connected, deliver the above types of tweets live (without querying)

# Runtime Commands
1. Extract the contents of the zip file.
2. And CD into the inner folder `project4_part1` and run the command `mix erscipt.build`
3. At first, run the server by using the command `erscipt project4_part1 server numClient`, `numClient` is the number of the clients.
4. And then, we run the client by using the command `erscipt project4_part1 client numUser numMessage`, the `numUser` is the number of users and the `numMessage` is the number of message per user. 
`Note`: The number of client windows that you open on the terminal should equal to the `numClient` parameter that you passed when launching the server. 
5. And fianlly, run the test by using `mix test` which  we create a new thread to track the values of related parameters during program operation.
`Note`:If something wrong, please try again, and please run the server and client firstly, and then run the `mix test`.
6. We also provide a command to test each individual function `erscipt project4_part1 test`, in the part, we test the function of registering the account, creating the tweet, login/out and query function by calling the corresponding function.   
`Note`: The individual test function is similar to open the client that open the server firstly, and open another terminal to run the `erscipt project4_part1 test`.
`Note`: Please close all the terminal when you finish once test and don't open another client immediately, wait a second, and if something wrong, try again, thank you.

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

 
# Sample Input/Output 1
Input -> Server: `./project4_part1 server 1`<br>
Output-> Server: <br>
`"10.20.124.3"`<br>
`:"server@10.20.124.3"`<br>
`"register an account"`<br>
`"register an account"`<br>
`"register an account"`<br>
...........
`"register an account"`<br>
`"Number of tweets per 5 second = 400"`<br>
`"Number of tweets per 5 second = 20"`<br>

Input -> Client: `./project4_part1 client 20 20`<br>
Output -> Client: <br>
`"user1" subscribed 1 user "user4"` <br>
`"user1" subscribed 2 user "user12"` <br>
........
`"user1" subscribed 2 user "user12"` <br>
`:user3 At :"localhost-75@10.20.124.3":Got "#k44z1kpu" "igkejlwgfqiuxpqekxernnsbqrpxtkwg" from :user1 At :"localhost-75@10.20.124.3"` <br>
`Retweet: :user17 At :"localhost-75@10.20.124.3":Got "#7e6vs8lcydehscwoeusluubalgdheogamqqtbhje from:user5" from :user4 At :"localhost-75@10.20.124.3"` <br>
.........
`:user16 At :"localhost-75@10.20.124.3":Got "wtruiaqnybvpjzwpavnlwkvfqfmtcxgi" "@user13" from :user8 At :"localhost-75@10.20.124.3""` <br>
we can see that there is the tweet with hashtag, for example the first tweet above, and the tweet with mention, for example the last tweet.And the retweet for exampe the second tweet.

And then, we can run the test with `mix test`:
`the output is:`
"The user list is:"
:user1
:user2
:user3
:user4
:user5
:user6
:user7
:user8
:user9
:user10
:user11
:user12
:user13
:user14
:user15
:user16
:user17
:user18
:user19
:user20

`"Test the Query"`
The tweets of hashtag "#ypfhjiqg" includes "qakxgzyklgrvumwttivrrnveejfxmdtj"
The tweets of mention "@user5" includes "yfcavpqbpmvdbfanoxqbevpdgvdjcoiw"
The tweets of mention "@user5" includes "bbvlujjdqkxirggtcajvvpoccnypiqvw"
The tweets of mention "@user5" includes "ddfzstnwttmqqwdrutilrbtnciufbmwq"
The tweets of mention "@user5" includes "kwpddbytezwqrzhoxslpjszzxvbvgugg"
The tweets of mention "@user5" includes "kyciwodtjbmgijpylbayklmagydmvena"
The tweets of mention "@user5" includes "pikzvvlfnijqivuxmlccstsunyrknigf"
The tweets of mention "@user5" includes "yzreujszudscgmbcwgysiawpdstinelc"


`"Test the account Subscribe"`
The subscriber of :user1 includes
:user1
:user3
:user4
:user11
:user13
:user17
The subscriber of :user2 includes
:user3
:user4
:user5
:user7
:user12
:user14
:user15
:user16
:user18
:user19
The subscriber of :user3 includes
:user3
:user4
:user5
:user6
:user7
:user8
:user13
:user15
:user17
:user18
The subscriber of :user4 includes
:user1
:user3
:user5
:user6
:user9
:user10
:user11
:user12
:user13
:user18
:user20
The subscriber of :user5 includes
:user1
:user4
:user5
:user9
:user10
:user12
:user14
:user20
The subscriber of :user6 includes
:user5
:user7
:user9
:user10
:user12
:user18
:user19
The subscriber of :user7 includes
:user1
:user2
:user8
:user10
:user15
:user20
The subscriber of :user8 includes
:user1
:user3
:user5
:user6
:user15
:user17
:user18
The subscriber of :user9 includes
:user2
:user5
:user6
:user8
:user11
:user13
:user17
:user18
:user19
:user20
The subscriber of :user10 includes
:user1
:user3
:user10
:user12
:user14
:user17
The subscriber of :user11 includes
:user4
:user7
:user10
:user12
:user15
:user16
:user18
:user19
The subscriber of :user12 includes
:user3
:user4
:user6
:user11
:user16
:user17
:user19
The subscriber of :user13 includes
:user2
:user6
:user7
:user8
:user9
:user10
:user14
:user15
:user16
:user20
The subscriber of :user14 includes
:user5
:user6
:user7
:user13
:user14
:user15
:user16
:user17
:user18
:user19
The subscriber of :user15 includes
:user5
:user8
:user11
:user12
:user13
:user14
:user20
The subscriber of :user16 includes
:user2
:user3
:user4
:user7
:user9
:user13
:user14
:user16
:user17
The subscriber of :user17 includes
:user9
:user13
:user14
:user16
:user19
:user20
The subscriber of :user18 includes
:user1
:user6
:user8
:user9
:user11
:user18
:user20
The subscriber of :user19 includes
:user1
:user2
:user4
:user9
:user11
:user12
:user13
:user14
:user18
:user19
The subscriber of :user20 includes
:user2
:user10
:user11
:user15

`"The user list after delete one user randomly is:"`
:user1
:user2
:user3
:user4
:user5
:user6
:user7
:user8
:user10
:user11
:user12
:user13
:user14
:user15
:user16
:user17
:user18
:user19
:user20

#### Sample Input/Output 2
Input -> Server: `./project4_part1 server 2`<br>
Output-> Server: <br>
`"10.20.124.3"`<br>
`:"server@10.20.124.3"`<br>
`"register an account"`<br>
`"register an account"`<br>
`"register an account"`<br>
...........
`"register an account"`<br>
`"Number of tweets per 5 second = 200"`<br>
`"Number of tweets per 5 second = 20"`<br>

Input -> Client 1: `./project4_part1 client1 10 10`<br>
Output -> Client 1: <br>
`"user1" subscribed 1 user "user7"` <br>
`"user1" subscribed 2 user "user3"` <br>
........
`"user10" subscribed 5 user "user8"` <br>
`:user1 At :"localhost-50@10.20.124.3":Got "#ijhwnbjb" "ilvgnlhzbwjdqfpdluveftcfawuiumoz" from :user1 At :"localhost-50@10.20.124.3"` <br>
`:user4 At :"localhost-50@10.20.124.3":Got "jemjpocildggbvpitmtpmsxjfvjibiek" "@user8" from :user4 At :"localhost-50@10.20.124.3"` <br>
.........
`:user9 At :"localhost-50@10.20.124.3":Got "onksdcxgsdfvbgcitcckvqcgwkxbubjo" from :user2 At :"localhost-50@10.20.124.3"` <br>
`Retweet: :user10 At :"localhost-50@10.20.124.3":Got "#xolggkx4yroxvvwlchonbewcmcbqytvjwqlrkril from:user4" from :user10 At :"localhost-50@10.20.124.3"`<br>
we can see that there is the tweet  with hashtag, for example the first tweet above, and the tweet with mention, for example the second tweet. And the retweet, for example the third one.

Input -> Client 2: `./project4_part1 client1 10 10`<br>
Output -> Client 2: <br>
`"user11" subscribed 1 user "user19"`<br>
`"user11" subscribed 2 user "user8"` <br>

........
`"user20" subscribed 9 user "user7"` <br>
`"user20" subscribed 10 user "user5"` <br>
`:user11 At :"localhost-B0@10.20.124.3":Got "#04lgk61f" "udzoqgdzwbjmbhguuoflatymbggvboki" from :user11 At :"localhost-B0@10.20.124.3"` <br>
`:user13 At :"localhost-B0@10.20.124.3":Got "tbnsfxgqaykrsdtmiitqhncecngxsxjz" from :user11 At :"localhost-B0@10.20.124.3"` <br>
.........
`Retweet: :user12 At :"localhost-B0@10.20.124.3":Got "#286tds8hztrfvamndrrypxeelbujcbfhfdddqadt from:user15" from :user15 At :"localhost-B0@10.20.124.3"` <br>
we can see that there is the tweet  with hashtag, for example the first tweet above, and the tweet with mention, for example the second tweet. And the retweet, for example the third one.


And then, we can run the test with `mix test`:
`the output is:`
"The user list is:"
:user1
:user2
:user3
:user4
:user5
:user6
:user7
:user8
:user9
:user10
:user11
:user12
:user13
:user14
:user15
:user16
:user17
:user18
:user19
:user20
`"Test the Query"`
The tweets of hashtag "#anhnhymu" includes "xszybrxevmodubufbcxemsrefbppaayg"
The tweets of mention "@user2" includes "xkfxrakxsfcqknokcacqdmjrlsykghcn"
The tweets of mention "@user2" includes "txdcvayokspcatsfqsfwwcwvtyzjtnue"
The tweets of mention "@user2" includes "riqqtihaxzcgdtxqecyrnsctzhamfbmi"
The tweets of mention "@user2" includes "jiigxmhoilunftpsqxhrkrzhbxddlgpd"
The tweets of mention "@user2" includes "yzdqgkhjpscbyuevamtkdcbabsvywfij"
The tweets of mention "@user2" includes "lfsjduheaubqoyutbabkfwebssqeuhta"
`"Test the Subscribe"`
The subscriber of :user1 includes
:user1
:user2
:user3
:user5
:user6
:user19
The subscriber of :user2 includes
:user3
:user4
:user7
:user9
:user12
:user13
:user14
:user17
:user18
:user19
The subscriber of :user3 includes
:user3
:user4
:user8
:user9
:user12
:user15
:user16
:user20
The subscriber of :user4 includes
:user4
:user7
:user8
:user9
:user10
:user12
:user13
:user16
:user17
:user19
The subscriber of :user5 includes
:user2
:user5
:user11
:user15
:user16
The subscriber of :user6 includes
:user1
:user3
:user5
:user6
:user9
:user13
:user18
:user19
:user20
The subscriber of :user7 includes
:user1
:user2
:user12
:user14
:user15
:user16
The subscriber of :user8 includes
:user4
:user6
:user7
:user8
:user10
:user13
:user14
:user15
:user16
The subscriber of :user9 includes
:user2
:user8
:user10
:user11
:user17
:user18
:user19
The subscriber of :user10 includes
:user4
:user5
:user8
:user10
:user13
:user14
:user15
:user18
:user20
The subscriber of :user11 includes
:user11
:user12
:user14
:user15
:user18
:user20
The subscriber of :user12 includes
:user12
:user13
:user15
The subscriber of :user13 includes
:user11
:user13
:user14
:user16
:user17
:user20
The subscriber of :user14 includes
:user15
:user19
The subscriber of :user15 includes
:user16
:user17
:user18
The subscriber of :user16 includes
:user11
:user12
:user13
:user15
The subscriber of :user17 includes
:user11
:user13
:user16
:user17
:user20
The subscriber of :user18 includes
:user11
:user14
:user20
The subscriber of :user19 includes
:user12
:user16
:user20
The subscriber of :user20 includes
:user11
:user16
:user17
:user18
:user19
`"The user list after delete one user randomly is:"`
:user1
:user2
:user3
:user4
:user5
:user7
:user8
:user9
:user10
:user11
:user12
:user13
:user14
:user15
:user16
:user17
:user18
:user19
:user20

For the `individual test`, the code shows below:
`Project4Part1.Node.register("user1", "123", server_name, Node.self, 1)`
`Project4Part1.Node.register("user2", "123", server_name, Node.self, 2)`
`Project4Part1.Node.register("user3", "123", server_name, Node.self, 3)`
`Project4Part1.Node.create_a_common_tweet("user1", "I am the first_tweeter")`
`Project4Part1.Node.subscribe_other_user("user2","user1")`
`Project4Part1.Node.subscribe_other_user("user3","user1")`
`:timer.sleep(2000);`
`Project4Part1.Node.create_a_tweet_with_hashTag("user1", "This is my second tweet","user 2")`
`Project4Part1.Node.logout("user3")`
`IO.puts "Test the logout"`
`Project4Part1.Node.create_a_common_tweet("user1", "This is my third tweet")`
`:timer.sleep(2000);`
`Project4Part1.Node.login("user3","123",server_name)`
`IO.puts "Test the Query"`
`{random_hash,hash_tweet}=Project4Part1.Node.get_hashtag(server_name)`
`Enum.each(hash_tweet,fn(x)-> IO.puts "The tweet of hashtag #{inspect random_hash} includes #{inspect x}" end)`
In the code, we register three users by ourselves and create a tweet for user1 and add the subscriber for user2 and user3, so the user1 and user2 can get the tweet from user1. And then the user3 logout, user3 can't get the second tweet from user1 but user2 can get the tweet beacuse user3  log out. And when user3 login, after calling the query, user3 can get the tweet which user1 sent during the time user3 log out. An we test the querying the tweet with hashtag. The result shows below:
`:user2 At :"localhost-FA@10.20.124.3":Got "#user 2" "This is my second tweet" from :user1 At :"localhost-FA@10.20.124.3"`
`:user3 At :"localhost-FA@10.20.124.3":Got "#user 2" "This is my second tweet" from :user1 At :"localhost-FA@10.20.124.3"`
`Test the logout`
`:user2 At :"localhost-FA@10.20.124.3":Got "This is my third tweet" from :user1 At :"localhost-FA@10.20.124.3"`
`Test the Query`
`The tweet of hashtag "#user 2" includes "This is my second tweet"`
