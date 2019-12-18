defmodule Proj4p2Web.RoomChannel do

  # use Proj4p2Web, :channel
  use Phoenix.Channel
  use GenServer

  #starthere that every user should have a pid
  def join("room:lobby", _auth_message, socket)  do
    {:ok,socket}
  end

  def handle_in("simulate",  %{"client_id" => client_id}, socket)do
    create_client(1, 100, 100, socket)
    get_subscribe(1, 100)
    get_random_tweet(1, 100, 100)

    {:noreply, socket}

  end

  def get_random_tweet(count, number_clients, number_tweets) do
    username=to_string(count)
    tweet=Proj4p2.LibFunctions.randomizer(32,:downcase)

    for _ <- 1..number_tweets do
      tweet=Proj4p2.LibFunctions.randomizer(32,:downcase)
      GenServer.cast(Boss_Server,{:got_a_commontweet, tweet,to_string(count)})
    end
    hashtag="#"<>Proj4p2.LibFunctions.randomizer(5,:downcase)
    mention="@"<>Proj4p2.LibFunctions.randomizer(4,:downcase)
    GenServer.cast(Boss_Server,{:got_a_commontweet, tweet<>hashtag,to_string(count)})
    GenServer.cast(Boss_Server,{:got_a_tweet_withHashTag, tweet<>hashtag<>mention, username, hashtag})

    GenServer.cast(Boss_Server,{:got_a_commontweet, tweet<>mention,to_string(count)})
    GenServer.cast(Boss_Server,{:got_a_mention_tweet,  tweet<>hashtag<>mention, username, mention})


    if (count != number_clients) do get_random_tweet(count + 1, number_clients, 2) end
  end

  def get_subscribe(count, number_clients) do
    subscribe_num = :rand.uniform(number_clients) - 1
    targets = Enum.take_random(Enum.to_list(1..number_clients), subscribe_num)

    Enum.each targets, fn target_client ->
      if to_string(target_client) != to_string(count) do
        GenServer.cast(Boss_Server,{:subscribe_other_user,to_string(count), to_string(target_client)})
      end
    end

  end








  def create_client(count, number_clients, number_tweets, socket) do
    username = Integer.to_string(count)
    node_name = String.to_atom("client@" <> to_string(username))
    {:ok, client_pid} = GenServer.start_link(__MODULE__, [username, node_name, socket], name: node_name)
    GenServer.cast(Boss_Server ,{:create_user, node_name,"",username,client_pid, socket})
    if (count != number_clients) do create_client(count + 1,number_clients,number_tweets, socket) end
  end


  def handle_in("connect_boss", %{"client_id" => client_id}, socket)do

    node_name = String.to_atom("client@" <> to_string(client_id))
    {:ok, client_pid} = GenServer.start_link(__MODULE__, [client_id, node_name, socket], name: node_name)
    GenServer.cast(Boss_Server ,{:create_user, node_name,"",client_id,client_pid, socket})

    {:noreply, socket}

  end

  def handle_in("send", %{"tweet" => tweet, "client_id" => client_id, "retweet" => retweet, "hashtag"=> hashtag,"mention"=> mention}, socket) do
     t=tweet<>hashtag<>mention
    if retweet == false do
      GenServer.cast(Boss_Server,{:got_a_commontweet, tweet<>hashtag<>mention,client_id})
      if(hashtag!="") do
        GenServer.cast(Boss_Server,{:got_a_tweet_withHashTag, tweet<>hashtag<>mention, client_id, hashtag})
      end
      if(mention!="") do
        GenServer.cast(Boss_Server,{:got_a_mention_tweet,  tweet<>hashtag<>mention, client_id, mention})
      end
    end
    broadcast socket, "send", %{"tweet" => t, "client_id" => client_id}

    {:noreply, socket}
  end

  def handle_in("tweet", %{"tweet" => tweet, "client_id" => client_id}, socket) do
    # IO.puts(client_id <> "Get Tweet: " <> tweet)
    broadcast socket, "tweet", %{"tweet" => tweet, "client_id" => client_id}

    {:noreply, socket}
  end



  # State in GenServer is a list here, it contains nodedata.
  # index_0 : the id of user (starting from 1)
  # index_1 : client node name
  # index_2 : socket

  def init(state) do

    {:ok, state}
  end

  def handle_cast({:test,test},state) do

    IO.inspect(test);

    {:noreply,state}
  end

  def handle_cast({:get_tweet, tweet}, state) do

      socket = Enum.at(state, 2)
      client_id = Enum.at(state, 0)
      IO.puts("client@" <> client_id <> " Got Tweet: " <> tweet)
      push(socket, "tweet", %{tweet: tweet, client_id: client_id})
      # IO.puts("client #{client_id} get tweet: #{tweet}")
      {:noreply,state}
    end





  def handle_in("query_all_my_tweets",%{"client_id" => client_id}, socket) do
    GenServer.cast(Boss_Server,{:got_a_mytweet, client_id})
    {:noreply,socket}
  end

  def handle_in("subscribe_query",%{"client_id" => client_id}, socket) do
    GenServer.cast(Boss_Server,{:got_subscriber_tweet, client_id})
    {:noreply,socket}
  end

  def handle_in("subscribe",%{"client_id" => client_id , "target_id" => target_id},socket)do
    GenServer.cast(Boss_Server,{:subscribe_other_user,target_id,client_id})
    {:noreply, socket}
  end

  def handle_in("get_list",%{"client_id" => client_id}, socket) do
    GenServer.call(Boss_Server,{:get_list_users,client_id},:infinity)
    {:noreply,socket}
  end

  def handle_in("get_mentionlist",%{"client_id" => client_id}, socket) do
    GenServer.call(Boss_Server,{:get_mentionlist_users,client_id},:infinity)
    {:noreply,socket}
  end

  def handle_in("get_hashtaglist",%{"client_id" => client_id}, socket) do
    GenServer.call(Boss_Server,{:get_hashtaglist,client_id},:infinity)
    {:noreply,socket}
  end

  def handle_in("mention_query",%{"client_id" => client_id,"mention"=> mention}, socket) do

    GenServer.cast(Boss_Server,{:query_by_mention, client_id,mention})

    {:noreply,socket}
  end

  def handle_in("hashtag_query",%{"client_id" => client_id, "hashtag" => hashtag}, socket) do

    GenServer.cast(Boss_Server,{:query_by_hashtag, client_id, hashtag})

    {:noreply,socket}
  end

end
