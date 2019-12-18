defmodule Proj4p2.Node do
    use GenServer

######################################Server Side Implementation####################################
    def init(args) do  

        {:ok,%{:is_logged_in=>true,:is_fresh_user=>true,:boss_node=>args, :clientName => nil, :nodeName => nil,:tweet_text_buffer => {}}}
    end

    def handle_cast({:create_a_common_tweet,tweet_text},state)do
        server_node_name=state[:boss_node]
        GenServer.cast({Boss_Server,server_node_name},{:got_a_commontweet,tweet_text,state[:clientName],state[:nodeName]})
        {:noreply,state}
    end

    def handle_cast({:create_a_tweet_with_hashTag,tweet_text,hashTag},state)do
        addinghashTag="#"<>hashTag
        server_node_name=state[:boss_node]
        GenServer.cast({Boss_Server,server_node_name},{:got_a_tweet_withHashTag,tweet_text,addinghashTag,state[:clientName],state[:nodeName]})
        {:noreply,state}
    end

    def handle_cast({:create_a_mention_tweet,tweet_text,mentioned_user},state)do
        server_node_name=state[:boss_node]
        GenServer.cast({Boss_Server,server_node_name},{:got_a_mention_tweet,state[:nodeName],state[:clientName],tweet_text,mentioned_user})
        {:noreply,state}
    end

    def handle_cast({:retweet_a_tweet_got_before,index},state)do
        server_node_name=state[:boss_node]
        text=elem(state[:tweet_text_buffer],index)
        tweet_text=Atom.to_string(text)
        GenServer.cast({Boss_Server,server_node_name},{:got_a_retweet,state[:nodeName],state[:clientName],tweet_text})
        {:noreply,state}
    end
    def handle_cast({:subscribe_other_user,other_user},state) do
        server_node_name=state[:boss_node]
        GenServer.cast({Boss_Server,server_node_name},{:subscribe_other_user,other_user,state[:clientName]})
        {:noreply,state}
    end
    def handle_cast({:subscribed_by_other_user,username},state)do
        server_node_name=state[:boss_node]
        GenServer.cast({Boss_Server,server_node_name},{:subscribed_by_other_user,String.to_atom(username),{state[:clientName],state[:nodeName],7}})
        {:noreply,state}
    end
    def handle_cast({:got_a_common_tweet,tweet_text,name_of_user,client_node_name},state) do
        IO.puts "#{inspect state[:clientName]} At #{inspect state[:nodeName]}:Got #{inspect tweet_text} from #{inspect name_of_user} At #{inspect client_node_name}"
        buffertweet=String.to_atom(tweet_text<>" from:"<>Atom.to_string(name_of_user))
        {_,state_buffer}=Map.get_and_update(state,:tweet_text_buffer, fn current_value -> {current_value,Tuple.append(current_value, buffertweet)} end)
        state=Map.merge(state,state_buffer)
        {:noreply,state}
    end
    def handle_cast({:got_a_tweet_with_hashTag,tweet_text,hashtag,name_of_user,client_node_name},state) do
        IO.puts "#{inspect state[:clientName]} At #{inspect state[:nodeName]}:Got #{inspect hashtag} #{inspect tweet_text} from #{inspect name_of_user} At #{inspect client_node_name}"
        buffertweet=String.to_atom(hashtag<>tweet_text<>" from:"<>Atom.to_string(name_of_user))
        {_,state_buffer}=Map.get_and_update(state,:tweet_text_buffer, fn current_value -> {current_value,Tuple.append(current_value, buffertweet)} end)
        state=Map.merge(state,state_buffer)
        {:noreply,state}
    end
    def handle_cast({:got_a_tweet_with_reference,tweet_text,reference,name_of_user,client_node_name},state) do
        IO.puts "#{inspect state[:clientName]} At #{inspect state[:nodeName]}:Got #{inspect tweet_text} #{inspect reference} from #{inspect name_of_user} At #{inspect client_node_name}"
        buffertweet=String.to_atom(tweet_text<>reference<>" from:"<>Atom.to_string(name_of_user))
        {_,state_buffer}=Map.get_and_update(state,:tweet_text_buffer, fn current_value -> {current_value,Tuple.append(current_value, buffertweet)} end)
        state=Map.merge(state,state_buffer)
        {:noreply,state}
    end
    def handle_cast({:got_a_retweet,tweet_text,name_of_user,client_node_name},state)do
        IO.puts "Retweet: #{inspect state[:clientName]} At #{inspect state[:nodeName]}:Got #{inspect tweet_text} from #{inspect name_of_user} At #{inspect client_node_name}"
        buffertweet=String.to_atom(tweet_text<>" from:"<>Atom.to_string(name_of_user))
        {_,state_buffer}=Map.get_and_update(state,:tweet_text_buffer, fn current_value -> {current_value,Tuple.append(current_value, buffertweet)} end)
        state=Map.merge(state,state_buffer)
        {:noreply,state}
    end
    def check_for_probability_for_retweet() do
        list=Enum.to_list(1..1000)
        value=false
        if(Enum.random(list)>700) do
            value=true
            value
        else
            value
        end
    end

    def handle_cast({:query},state)do
          # {:ok,%{:is_logged_in=>true,:is_fresh_user=>true,:boss_node=>args, :clientName => nil, :clientNode => nil }}
          GenServer.cast({Boss_Server,state[:boss_node]},{:query,state[:nodeName],state[:clientName]})
          {:noreply,state}
    end

    def handle_cast({:update_client_state,clientName,nodeName},state)do

        {_,state_isLoggedIn}=Map.get_and_update(state,:clientName, fn current_value -> {current_value,clientName} end)
        state=Map.merge(state,state_isLoggedIn)

        {_,state_isLoggedIn}=Map.get_and_update(state,:nodeName, fn current_value -> {current_value,nodeName} end)
        state=Map.merge(state,state_isLoggedIn)

        {_,state_isLoggedIn}=Map.get_and_update(state,:is_fresh_user, fn current_value -> {current_value,false} end)
        state=Map.merge(state,state_isLoggedIn)
        
        {:noreply,state}
    end

########################################Client Side Implementation################################
    # register an account 
    def register(nodename, password, server_node_name, client_node_name, id) do
        name_of_node = String.to_atom(nodename)
        {:ok,_} = GenServer.start_link(__MODULE__,server_node_name,name: name_of_node)
        GenServer.cast({name_of_node,Node.self()}, {:update_client_state,name_of_node,Node.self()})
        GenServer.cast({Boss_Server,server_node_name},{:create_user,client_node_name,password,name_of_node,id})
        #need to change
        {name_of_node,client_node_name}
    end
    #delete an account
    def delete(nodename, password, server_node_name, client_node_name) do
        name_of_node = String.to_atom(nodename)
        GenServer.cast({Boss_Server,server_node_name},{:delete_user,name_of_node,password,client_node_name})
        GenServer.stop({name_of_node,Node.self()}, :normal, :infinity)
        {name_of_node,client_node_name}
    end
    #login, registered before
    def login(nodename, _password, server_node_name)do
        name_of_node = String.to_atom(nodename)
        {:ok,_} = GenServer.start_link(__MODULE__,server_node_name,name: name_of_node)
        GenServer.cast({name_of_node,Node.self()}, {:update_client_state,name_of_node,Node.self()})
        #query_latest_tweets(nodename)
        {name_of_node}
    end

    #logout, terminate this process
    def logout(nodename)do
        name_of_node = String.to_atom(nodename)
        GenServer.stop({name_of_node,Node.self()}, :normal, :infinity)
    end
    def create_a_common_tweet(name_of_node, tweet_text)do
        GenServer.cast({String.to_atom(name_of_node),Node.self()}, {:create_a_common_tweet,tweet_text})
    end
    def create_a_tweet_with_hashTag(name_of_node, tweet_text, hashtag)do
        GenServer.cast({String.to_atom(name_of_node),Node.self()}, {:create_a_tweet_with_hashTag,tweet_text,hashtag})
    end
    def create_a_mention_tweet(name_of_node, tweet_text, mentioned_user)do
        GenServer.cast({String.to_atom(name_of_node),Node.self()}, {:create_a_mention_tweet,tweet_text,mentioned_user})
    end
    def retweet_a_tweet_got_before(name_of_node,tweet_buffer_index)do
        GenServer.cast({String.to_atom(name_of_node),Node.self()},{:retweet_a_tweet_got_before,tweet_buffer_index})
    end
    def query_latest_tweets(name_of_node)do
        GenServer.cast({String.to_atom(name_of_node),Node.self()},{:query})
    end
    def subscribe_other_user(nodename, other_user)do
        name_of_node=String.to_atom(nodename)
        GenServer.cast({name_of_node,Node.self()}, {:subscribe_other_user,other_user})
        GenServer.cast({name_of_node,Node.self()}, {:subscribed_by_other_user,other_user})
    end
    def get_users_list(server_name)do
        list=GenServer.call({Boss_Server,server_name},{:get_list_users},:infinity)
        list
    end
    def get_sub_list(server_name,client_name,node_name)do
        sublist=GenServer.call({Boss_Server,server_name},{:get_sub_list,client_name,node_name},:infinity)
        sublist
    end

    def get_hashtag(server_name)do
        {random_hash,hash_tweet}=GenServer.call({Boss_Server,server_name},{:get_hashtag},:infinity)
        {random_hash,hash_tweet}
    end

    def get_mention(server_name)do
        {random_mention,mention_tweet}=GenServer.call({Boss_Server,server_name},{:get_mention},:infinity)
        {random_mention,mention_tweet}
    end

    def delete_random(server_name)do
        list=GenServer.call({Boss_Server,server_name},{:get_list_users},:infinity)
        list_random=List.delete(list,Enum.random(list))
        list_random
    end

    def generate_name(args) do
        machine = to_string("localhost")
        IO.inspect args
        ipaddress=to_string(Enum.at(args,3))
        hex = :erlang.monotonic_time() |>
          :erlang.phash2(256) |>
          Integer.to_string(16)
        String.to_atom("#{machine}-#{hex}@#{ipaddress}")
    end
    
    def start_client(args)do
        clientName=generate_name(args)
        {:ok,_}= Node.start(clientName)
        cookie=Application.get_env(:project4_part1, :cookie)
        Node.set_cookie(cookie)
        {Node.self,args}
    end


end
