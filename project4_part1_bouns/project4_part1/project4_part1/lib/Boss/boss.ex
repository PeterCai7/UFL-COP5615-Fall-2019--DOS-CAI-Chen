defmodule Project4Part1.Boss do
use GenServer


def init(:ok) do
        period_compute()
        #ETS start
        :ets.new(:users, [:bag, :protected, :named_table])
        :ets.new(:tweets, [:bag, :protected, :named_table])
        :ets.new(:user_list, [:set, :protected, :named_table])
        :ets.new(:hashTags, [:bag, :protected, :named_table])
        :ets.new(:hashTags_tweet, [:bag, :protected, :named_table])
        :ets.new(:hashtag_list, [:set, :protected, :named_table])
        :ets.new(:mention_list, [:set, :protected, :named_table])
        :ets.new(:mention_tweet, [:bag, :protected, :named_table])
        :ets.new(:user_mention_tweets, [:bag, :protected, :named_table])
        :ets.new(:retweets, [:bag, :protected, :named_table])
        :ets.insert_new(:user_list,{"user_list",[]})
        :ets.insert_new(:hashtag_list,{"hashtag_list",[]})
        :ets.insert_new(:mention_list,{"mention_list",[]})


        {:ok,%{:start_value=>1,:number_of_tweets_before=>0, :number_of_tweets_after=>0, :number_of_retweets_before=>0,:number_of_retweets_after=>0,:hashTag=>[],:count_numClients=>0,:numClients=>0}}
end

def period_compute() do
        Process.send_after(self(), :periodic_compute, 5*1000)
end

def handle_info(:periodic_compute, state) do
        number_of_tweets_change=state[:number_of_tweets_after] - state[:number_of_tweets_before]
        number_of_retweets_change=state[:number_of_retweets_after]-state[:number_of_retweets_before]
        
        number_of_tweets_after=state[:number_of_tweets_after]
        number_of_retweets_after=state[:number_of_retweets_after]

        {_,state_retweets}=Map.get_and_update(state,:number_of_retweets_before, fn current_value -> {current_value,number_of_retweets_after} end)
        state=Map.merge(state,state_retweets)

        {_,state_tweets}=Map.get_and_update(state,:number_of_tweets_before, fn current_value -> {current_value,number_of_tweets_after} end)
        state=Map.merge(state,state_tweets)

        IO.puts "Number of tweets per 5 second = #{inspect number_of_tweets_change}"
        IO.puts "Number of retweets per 5 second = #{inspect number_of_retweets_change}"

        period_compute()
        {:noreply, state}
end

def handle_call({:get_list_users}, _from,state)do
        user_list=:ets.lookup(:user_list, "user_list")
        elem=Enum.at(user_list,0)
        list=elem(elem,1)
   #     sub=subscried_list_for_client(elem(rand,0),elem(rand,1),state)
        {:reply,list,state}
end

def handle_call({:get_sub_list,client_name,node_name}, _from,state)do
  user_list=:ets.lookup(:user_list, "user_list")
  elem=Enum.at(user_list,0)
  list=elem(elem,1)
  sub=subscried_list_for_client(client_name,node_name,state)
  {:reply,sub,state}
end

def handle_call({:get_hashtag}, _from,state)do
  hashtag_list=:ets.lookup(:hashtag_list, "hashtag_list")
  elem=Enum.at(hashtag_list,0)
  list=elem(elem,1)
  random_hash=Enum.random(list)
  hash_list=:ets.lookup(:hashTags_tweet, random_hash)
  elem_tuple=Enum.at(hash_list,0)
  hash_tweet=elem(elem_tuple,1)
  {:reply,{random_hash,hash_tweet},state}
end

def handle_call({:get_mention}, _from,state)do
  mention_list=:ets.lookup(:mention_list, "mention_list")
  elem=Enum.at(mention_list,0)
  list=elem(elem,1)
  random_mention=Enum.random(list)
  mention_list=:ets.lookup(:mention_tweet, random_mention)
  elem_tuple=Enum.at(mention_list,0)
  mention_tweet=elem(elem_tuple,1)
  {:reply,{random_mention,mention_tweet},state}
end


def handle_cast({:delete_user,name_node,_password,node_client},state)do
        user_list=:ets.lookup(:user_list, "user_list")
        elem=Enum.at(user_list,0)
        list=elem(elem,1)
        :ets.insert(:user_list,{"user_list",List.delete(list,{name_node,node_client,0})})

        :ets.delete(:users,name_node)
        IO.puts "delete an account"
        {:noreply,state}
end

def handle_cast({:create_user,node_client,password,name_node,id},state)do

      map_change=%{:node_client => nil, :hashTags => [], :password => nil, :has_subscribed_to => [], :is_subscribed_by => [],:name_node => nil, :id => nil, :no_of_zipf_tweets =>0, :probability_of_zipf_functions=>0, :number_of_subscribers=>0 }

      map_change=%{map_change|name_node: name_node}
      map_change=%{map_change|password: password}
      map_change=%{map_change|node_client: node_client}
      map_change=%{map_change|id: id}
      #Update the user_list with the client and node tuple
        user_list=:ets.lookup(:user_list, "user_list")
        elem=Enum.at(user_list,0)
        list=elem(elem,1)
        list=list++[{name_node,node_client,0}]
        :ets.insert(:user_list,{"user_list",list})

        #Added it to the users table
        :ets.insert(:users,{name_node,map_change})
        IO.puts "register an account"
        {:noreply,state}
end

def handle_cast({:got_a_commontweet,tweet_text,username,nodename},state)do
  tweets_table_change=%{:tweet => nil, :name_of_user => nil, :client_node_name => nil}
  tweets_table_change=%{tweets_table_change|tweet: tweet_text}
  tweets_table_change=%{tweets_table_change|name_of_user: username}
  tweets_table_change=%{tweets_table_change|client_node_name: nodename}
  :ets.insert_new(:tweets,{username,tweets_table_change})
  #can change
  {_,state_tweets}=Map.get_and_update(state,:number_of_tweets_after, fn current_value -> {current_value,current_value+1} end)
  state=Map.merge(state,state_tweets)

  is_subscribed_by=subscried_list_for_client(username,nodename,state)
  Enum.each(is_subscribed_by,fn({client_name_x,client_node_name_x,y}) -> GenServer.cast({client_name_x,client_node_name_x},{:got_a_common_tweet,tweet_text,username,nodename})  end)
  {:noreply,state}
end

def handle_cast({:got_a_tweet_withHashTag,tweet_text,hashTag,username,nodename},state)do
  hashTag_table_change=%{:tweet => nil, :hashTag => nil, :name_of_user => nil, :client_node_name => nil}
  hashTag_table_change=%{hashTag_table_change|tweet: tweet_text}
  hashTag_table_change=%{hashTag_table_change|hashTag: hashTag}
  hashTag_table_change=%{hashTag_table_change|name_of_user: username}
  hashTag_table_change=%{hashTag_table_change|client_node_name: nodename}
  :ets.insert(:hashTags,{hashTag,hashTag_table_change})

  hashtag_list=:ets.lookup(:hashtag_list, "hashtag_list")
  elem=Enum.at(hashtag_list,0)
  list=elem(elem,1)
  list=list++[hashTag]
  :ets.insert(:hashtag_list,{"hashtag_list",list})
  test_empty_hashtag(hashTag)
  hash_list=:ets.lookup(:hashTags_tweet, hashTag)
  elem_tuple=Enum.at(hash_list,0)
  hash_tweet=elem(elem_tuple,1)
  hash_tweet=hash_tweet++[tweet_text]
  :ets.delete(:hashTags_tweet,hashTag)
  :ets.insert(:hashTags_tweet,{hashTag,hash_tweet})


  {_,state_tweets}=Map.get_and_update(state,:number_of_tweets_after, fn current_value -> {current_value,current_value+1} end)
  state=Map.merge(state,state_tweets)

  is_subscribed_by=subscried_list_for_client(username,nodename,state)
  Enum.each(is_subscribed_by,fn({client_name_x,client_node_name_x,y}) -> GenServer.cast({client_name_x,client_node_name_x},{:got_a_tweet_with_hashTag,tweet_text,hashTag,username,nodename})  end)
  {:noreply,state}
end

def test_empty_hashtag(hashTag) do
  hashTag_table_change=:ets.lookup(:hashTags_tweet, hashTag)
  if(length(hashTag_table_change)==0) do
    :ets.insert(:hashTags_tweet,{hashTag,[]})
  end
end



def subscried_list_for_client(client_name,client_node,state) do
        #index=Enum.find_index(state[:users], fn(x) -> x[:node_client] == client_node and x[:name_node]== client_name end)
        user_list=:ets.lookup(:users,client_name)
        elem=Enum.at(user_list,0)
        users_tuple=elem(elem,1)
        is_subscribed_by=users_tuple[:is_subscribed_by]
        #IO.inspect is_subscribed_by
        #IO.inspect is_subscribed_by

        is_subscribed_by
end
def handle_cast({:subscribe_other_user,otheruser,username},state)do
         # process_map=%{:node_client => nil, :hashTags => [], :password => nil, :has_subscribed_to => [], :is_subscribed_by => [],:name_node => nil, :id => nil}
  client_name=username;
 # client_node=elem(node,1)

  array_list=:ets.lookup(:users, client_name)
  elem_tuple=Enum.at(array_list,0)
  users_tuple=elem(elem_tuple,1)

  subscribed_change=users_tuple[:has_subscribed_to]
  subscribed_change=subscribed_change++[otheruser]


  {_,state_has_subscribed_to}=Map.get_and_update(users_tuple,:has_subscribed_to, fn current_value -> {current_value,subscribed_change} end)
  users_tuple=Map.merge(users_tuple,state_has_subscribed_to)

  :ets.delete(:users,client_name)
  :ets.insert(:users, {client_name,users_tuple})

  {:noreply,state}
end

def handle_cast({:got_a_retweet,client_node_name,name_of_user,tweet},state) do

  retweets_table_change=%{:tweet => nil, :name_of_user => nil, :client_node_name => nil}
  retweets_table_change=%{retweets_table_change|tweet: tweet}
  retweets_table_change=%{retweets_table_change|name_of_user: name_of_user}
  retweets_table_change=%{retweets_table_change|client_node_name: client_node_name}

  :ets.insert(:retweets,{name_of_user,retweets_table_change})
  {_,state_retweets}=Map.get_and_update(state,:number_of_retweets_after, fn current_value -> {current_value,current_value+1} end)
  state=Map.merge(state,state_retweets)

  #Get its subscribed user and send the given retweet
  is_subscribed_by=subscried_list_for_client(name_of_user,client_node_name,state)
  Enum.each(is_subscribed_by,fn({client_name_x,client_node_name_x,_}) -> GenServer.cast({client_name_x,client_node_name_x},{:got_a_retweet,tweet,name_of_user,client_node_name})  end)
  
  {:noreply,state}
end

def handle_cast({:got_a_mention_tweet,client_node_name,name_of_user,tweet,reference},state)do
  mentioner_tweets_table_change=%{:tweet => nil, :name_of_user => nil, :client_node_name => nil, :reference => nil}
  mentioner_tweets_table_change=%{mentioner_tweets_table_change|tweet: tweet}
  mentioner_tweets_table_change=%{mentioner_tweets_table_change|name_of_user: name_of_user}
  mentioner_tweets_table_change=%{mentioner_tweets_table_change|client_node_name: client_node_name}
  mentioner_tweets_table_change=%{mentioner_tweets_table_change|reference: reference}
  :ets.insert(:user_mention_tweets,{reference,mentioner_tweets_table_change})
  {_,state_tweets}=Map.get_and_update(state,:number_of_tweets_after, fn current_value -> {current_value,current_value+1} end)
  state=Map.merge(state,state_tweets)

  complete_reference="@"<>reference
  #Get its subscribed user and send the given tweet

  mention_list=:ets.lookup(:mention_list, "mention_list")
  elem=Enum.at(mention_list,0)
  list=elem(elem,1)
  list=list++[complete_reference]
  :ets.insert(:mention_list,{"mention_list",list})
  test_empty_mention(complete_reference)
  mention_list=:ets.lookup(:mention_tweet, complete_reference)
  elem_tuple=Enum.at(mention_list,0)
  mention_tweet=elem(elem_tuple,1)
  mention_tweet=mention_tweet++[tweet]
  :ets.delete(:mention_tweet,complete_reference)
  :ets.insert(:mention_tweet,{complete_reference,mention_tweet})

  is_subscribed_by=subscried_list_for_client(name_of_user,client_node_name,state)
  Enum.each(is_subscribed_by,fn({client_name_x,client_node_name_x,_}) -> GenServer.cast({client_name_x,client_node_name_x},{:got_a_tweet_with_reference,tweet,complete_reference,name_of_user,client_node_name})  end)

  #Send the mention tweet to user to the reference
  #GenServer.cast({reference,reference_node},{:got_mentioned,reference,reference_node,name_of_user,client_node_name,tweet,hashTag})

  {:noreply,state}
end

def test_empty_mention(mention) do
  mention_table_change=:ets.lookup(:mention_tweet, mention)
  if(length(mention_table_change)==0) do
    :ets.insert(:mention_tweet,{mention,[]})
  end
end

def handle_cast({:subscribed_by_other_user,username,other_user_node},state)do
  client_name=username
  #client_node=elem(random_node_choose,1)
  array_list=:ets.lookup(:users, client_name)
  user_list=:ets.lookup(:user_list, "user_list")
  elem=Enum.at(user_list,0)
  list=elem(elem,1)
  random=:rand.uniform(length(list))
  other_node={elem(other_user_node,0),elem(other_user_node,1),random}
  #IO.inspect array_list
  elem_tuple=Enum.at(array_list,0)
  #IO.inspect elem_tuple
  users_tuple=elem(elem_tuple,1)

  is_subscribed_to_channge=users_tuple[:is_subscribed_by]
  is_subscribed_to_channge=is_subscribed_to_channge++[other_node]
  is_subscribed_to_channge=Enum.uniq_by(is_subscribed_to_channge, fn {x, _, _} -> x end)

  number_of_subscribers_change=users_tuple[:number_of_subscribers]
  number_of_subscribers_change=length(is_subscribed_to_channge);



  {_,state_random_is_subscribed_by}=Map.get_and_update(users_tuple,:is_subscribed_by, fn current_value -> {current_value,is_subscribed_to_channge} end)
  users_tuple=Map.merge(users_tuple,state_random_is_subscribed_by)

  {_,state_number}=Map.get_and_update(users_tuple,:number_of_subscribers, fn current_value -> {current_value,number_of_subscribers_change} end)
  users_tuple=Map.merge(users_tuple,state_number)
  :ets.delete(:users, client_name)
  :ets.insert(:users, {client_name,users_tuple})
  {:noreply,state}
end

def handle_call({:get_random_tweet_for_mention,client_name,client_node},_from ,state) do

        #Tweet details
        tweet=Project4Part1.LibFunctions.randomizer(32,:downcase)
        hashTag="#"<>Project4Part1.LibFunctions.randomizer(8,true)
        
        #Take a random user not the same user for retweeting

         array_list=:ets.lookup(:user_list, "user_list")
         elem_tuple=Enum.at(array_list,0)
         list=elem(elem_tuple,1)

         #IO.inspect users_array_lis
        random_user_id_for_given_user=Enum.random(list)
       
        node=client_node
        tweet_by_user=client_name
        reference=elem(random_user_id_for_given_user,0)
        reference_node=elem(random_user_id_for_given_user,1)


        {:reply,{node,hashTag,tweet,tweet_by_user,reference,reference_node},state}
        #{:noreply,state}
end


def update_subscrib_number(list)do

      client_name=elem(list,0)
      user_array_list=:ets.lookup(:users,client_name)
      user_list=Enum.at(user_array_list,0)
      user_tuple=elem(user_list,1)

      user_tuple=%{user_tuple|number_of_subscribers: elem(list,2)}

      :ets.delete(:users, client_name)
      :ets.insert(:users, {client_name,user_tuple})

end

def handle_cast({:query,clientNode,clientName},state) do
                
                user_array_list=:ets.lookup(:users,clientName)
                user_list=Enum.at(user_array_list,0)
                user_tuple=elem(user_list,1)

                user_is_subscribed_list=user_tuple[:has_subscribed_to]
                #IO.inspect user_is_subscribed_list
                user_subscribed_latest_tweets_5=Enum.map(user_is_subscribed_list,fn x -> Enum.take(:ets.lookup(:tweets,String.to_atom(x)),-10) end)
                #IO.inspect user_subscribed_latest_tweets_5
                #{:got_a_tweet,Enum.at(tweets,x),Enum.at(hashTag,x),Enum.at(tweet_by_user,x),Enum.at(nodes_tweeting,x),nil,Map.get(userTuple,:name_node),Map.get(userTuple,:node_client)
                if(length(user_subscribed_latest_tweets_5)>0) do
                        array_list=Enum.at(user_subscribed_latest_tweets_5,0)
                        #IO.inspect array_list
                        Enum.each(Enum.with_index(array_list),fn({x,i})->
                        x_tuple=x
                        user_process_map=elem(x_tuple,1)
                        #IO.inspect user_process_map
                        GenServer.cast({clientName,clientNode},{:got_a_common_tweet,Map.get(user_process_map,:tweet),Map.get(user_process_map,:name_of_user),Map.get(user_process_map,:client_node_name)})
                        #IO.inspect Map.get(user_process_map,:tweet)
                        end)
                end


        {:noreply,state}
end

 def handle_cast({:update_num_client,numClients}, state) do
         {_,state_numClients}=Map.get_and_update(state,:numClients, fn current_value -> {current_value,numClients} end)
         state=Map.merge(state,state_numClients)
         {:noreply,state}
 end
 
 def start_boss(server_tuple) do
  serverName=String.to_atom(to_string("server@")<>elem(server_tuple,0))
  args=elem(server_tuple,1)
  numClients=String.to_integer(Enum.at(args,1))
  {:ok,_}=Node.start(serverName)
  cookie=Application.get_env(:project4_part1, :cookie)
  {:ok,_} = GenServer.start_link(__MODULE__, :ok, name: Boss_Server)  # -> Created the boss process
  GenServer.cast({Boss_Server,serverName},{:update_num_client,numClients})
  Node.set_cookie(cookie)
  :global.register_name(:boss_server,self())
  IO.inspect Node.self()
 end

end