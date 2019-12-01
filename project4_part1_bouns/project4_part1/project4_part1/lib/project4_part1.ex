defmodule Project4Part1 do
  def main(args \\ []) do

    if(length(args)==2) do
      #Create the server Processs
      Project4Part1.LibFunctions.get_ip_address(args)|>Project4Part1.Boss.start_boss
      loop()
    else if(length(args)==3) do
           {ip,_}=Project4Part1.LibFunctions.get_ip_address(args)
           args=args++[ip]
           tuple=Project4Part1.Node.start_client(args)
    #       IO.inspect Enum.at(elem(tuple,1),0)
     #      IO.inspect Enum.at(elem(tuple,1),1)
           num_users=String.to_integer(Enum.at(elem(tuple,1),1))
           num_tweets=String.to_integer(Enum.at(elem(tuple,1),2))
           server_name=String.to_atom(to_string("server@"<> Enum.at(elem(tuple,1),3)))
           list=Project4Part1.Node.get_users_list(server_name)
           value=Node.connect(server_name)
           startnum=length(list)
    #       IO.inspect value
           # register accounts
           Enum.map(startnum+1..num_users+startnum, fn x ->
            username="user"<>Integer.to_string(x)
            Project4Part1.Node.register(username, "123", server_name, Node.self, x)
           end)
           list=Project4Part1.Node.get_users_list(server_name)

           num_subscription=div(length(list),2)
           #IO.inspect num_subscription
           #add subscription
           Enum.map(startnum+1..num_users+startnum, fn x ->
            username="user"<>Integer.to_string(x)
            Enum.map(1..num_subscription, fn x -> 
              subscribed_user = Atom.to_string(elem(Enum.random(list),0))
              Project4Part1.Node.subscribe_other_user(username,subscribed_user)
              IO.puts "#{inspect username} subscribed #{inspect x} user #{inspect subscribed_user}" 
            end)
           end)
           #begin to tweet
           Enum.map(1+startnum..num_users+startnum, fn x ->
            username="user"<>Integer.to_string(x)
            Enum.map(1..num_tweets, fn x -> 
              case rem(x,3) do
                 0 -> Project4Part1.Node.create_a_common_tweet(username, Project4Part1.LibFunctions.randomizer(32,:downcase))
                 1 -> Project4Part1.Node.create_a_tweet_with_hashTag(username, Project4Part1.LibFunctions.randomizer(32,:downcase),Project4Part1.LibFunctions.randomizer(8,true))
                 2 -> Project4Part1.Node.create_a_mention_tweet(username, Project4Part1.LibFunctions.randomizer(32,:downcase), Atom.to_string(elem(Enum.random(list),0)))
              end
            end)
           end)
           #retweet
           Enum.map(1+startnum..num_users+startnum, fn x ->
            username="user"<>Integer.to_string(x)
            # Enum.map(1..num_tweets, fn x ->
            #   index = x-1
            Project4Part1.Node.retweet_a_tweet_got_before(username,0) 
            # end)
           end)

           # Project4Part1.Node.register("user1", "123", server_name, Node.self, 1)
           # :timer.sleep(2000);
       #     IO.puts "Test the delete"
           # Project4Part1.Node.delete("user1", "123", server_name, Node.self)
           # Project4Part1.Node.register("user2", "123", server_name, Node.self, 2)
           # Project4Part1.Node.register("user3", "123", server_name, Node.self, 3)
           # Project4Part1.Node.create_a_common_tweet("user1", "I am the first_tweeter")
           # Project4Part1.Node.subscribe_other_user("user2","user1")
           # Project4Part1.Node.subscribe_other_user("user3","user1")
           # :timer.sleep(2000);
           # Project4Part1.Node.create_a_common_tweet("user1", "This is my second tweet")
         #  IO.puts "Test the delete"
          #  Project4Part1.Node.logout("user3")
           # Project4Part1.Node.create_a_common_tweet("user1", "This is my 3rd tweet")
           # :timer.sleep(2000);
           # :timer.sleep(2000);
         #  IO.puts "Test the Query"
           # Project4Part1.Node.query_latest_tweets("user3")
           loop()
         else if(length(args)==1)do
                args=["test","1","1"]
                {ip,_}=Project4Part1.LibFunctions.get_ip_address(args)
                args=args++[ip]
                tuple=Project4Part1.Node.start_client(args)
                server_name=String.to_atom(to_string("server@"<> Enum.at(elem(tuple,1),3)))
                 Project4Part1.Node.register("user1", "123", server_name, Node.self, 1)
                 Project4Part1.Node.register("user2", "123", server_name, Node.self, 2)
                 Project4Part1.Node.register("user3", "123", server_name, Node.self, 3)
                 Project4Part1.Node.create_a_common_tweet("user1", "I am the first_tweeter")
                 Project4Part1.Node.subscribe_other_user("user2","user1")
                 Project4Part1.Node.subscribe_other_user("user3","user1")
                 :timer.sleep(2000);
                 Project4Part1.Node.create_a_tweet_with_hashTag("user1", "This is my second tweet","user 2")
                 Project4Part1.Node.logout("user3")
                 IO.puts "Test the logout"
                 Project4Part1.Node.create_a_common_tweet("user1", "This is my third tweet")
                 :timer.sleep(2000);
                 Project4Part1.Node.login("user3","123",server_name)
                 IO.puts "Test the Query"
                 {random_hash,hash_tweet}=Project4Part1.Node.get_hashtag(server_name)
                 Enum.each(hash_tweet,fn(x)-> IO.puts "The tweet of hashtag #{inspect random_hash} includes #{inspect x}" end)
                 loop()

              else
                IO.puts "Enter the arguments as mentioned in the documentation"
              end



         end
    end
  end

  def loop() do
    loop()
  end

end