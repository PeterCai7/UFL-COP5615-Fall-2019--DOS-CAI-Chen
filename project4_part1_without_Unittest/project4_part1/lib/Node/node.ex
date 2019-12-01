defmodule Project4Part1.Node do
    use GenServer

    @numTweets 1
    @numHashTags 1
    @numberOfSubscriptions 1
######################################Server Side Implementation####################################
    def init(args) do  
        #periods_of_connection_and_disconnection()
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
        if(Enum.random(list)>900) do
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
        l=GenServer.call({Boss_Server,server_name},{:get_list_users},:infinity)
        l
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

    def connect_to_server(tuple)do
    server_name=String.to_atom(to_string("server@"<> Enum.at(elem(tuple,1),3)))
    value=Node.connect(server_name)
    IO.inspect value
    {numNode,_}=Integer.parse(Enum.at(elem(tuple,1),1))
    numTweet=String.to_integer(Enum.at(elem(tuple,1),2))
    startValue=GenServer.call({Boss_Server,server_name},{:get_start_value},:infinity)
    #startValue=0
    GenServer.cast({Boss_Server,server_name},{:update_start_value,startValue+numNode})

    l= spawn_nodes(numNode+startValue,startValue,[],server_name,elem(tuple,0),numTweet)
    #IO.inspect l


    list=GenServer.call({Boss_Server,server_name},{:get_list_users},:infinity)

    # if(length(list)>0)do
    #     l=list
    # end

    l1=random_subscriptions(l,1,server_name)
    IO.inspect l1
    random_hashTags_for_a_given_user(server_name,@numHashTags,l,0)
    GenServer.cast({Boss_Server,server_name},{:increment_numClients,1,numNode,l1,l})
     #Send an Ack to server
        #Process.sleep(1_0000)

        #Enum.each(l,fn({name_node_x,client_node_x})-> GenServer.cast({Boss_Server,server_name},{:zipf_distribution,name_node_x,client_node_x,numNode})  end)
    end

    # def connecingToServer(server_name) do
    #     message=Node.connect(server_name)
    #     IO.inspect message
    # end

       # change 2
      def spawn_nodes(numNodes,start_value,l,server_node_name,client_node_name,numTweet) do

             if(start_value<numNodes) do
                name_of_node=Project4Part1.Node.start(start_value,server_node_name,client_node_name,numTweet)
                l=l++[name_of_node]
                create_tweet_for_user(numTweet,elem(name_of_node,0),1,server_node_name,client_node_name,start_value,nil)
                {name_of_node_node,client_node_name,_}=name_of_node
                GenServer.cast({name_of_node_node,client_node_name},{:mention_tweet,client_node_name,name_of_node_node})
                start_value=start_value+1
                l=spawn_nodes(numNodes,start_value,l,server_node_name,client_node_name,numTweet)
                l
             else
                l
             end
      end

      # def prob_initial_tweets(numNodes) do
      #     array_list=Enum.to_list(1..100)
      #     value=false
      #     if(Enum.random(array_list)==50)do
      #         value=true
      #     end
      #     value
      # end
    
      def create_tweet_for_user(numtweets,name_of_user,start_value,server_node_name,client_node_name,id_tweeter,reference)do
            if(start_value<=numtweets)do
                GenServer.cast({name_of_user,client_node_name},{:tweet,name_of_user,client_node_name,reference})
                start_value=start_value+1
                create_tweet_for_user(numtweets,name_of_user,start_value,server_node_name,client_node_name,id_tweeter,reference)
            end
      end

    # change 3
    def random_subscriptions(list, start,server_name) do

        if(start<=length(list)) do
            listLength=length(list)
            numberList=1..listLength
            random_number_subscriptions=Enum.random(numberList)-1
            #random_number_subscriptions=@numberOfSubscriptions
            element=Enum.at(list,start-1);
            newList=list--[element]
            #IO.inspect newList
            generate_subscriptions(newList,1,random_number_subscriptions,server_name,element)
            
            tuple_1=Tuple.delete_at(element,2)
            element=Tuple.insert_at(tuple_1, 2,random_number_subscriptions)

            newList=List.delete_at(list,start-1)
            list=List.insert_at(newList, start-1,element)
      #      IO.puts "#{inspect elem(list,2)}"
            start=start+1
            list=random_subscriptions(list, start,server_name)
            list
        else
            list
        end
    end

    def generate_subscriptions(list,startValue,random_number_subscriptions,server_name,node)do
       if(startValue<=random_number_subscriptions) do
           random_node_choose=Enum.random(list);
           #IO.inspect random_node_choose
           list=list--[random_node_choose]
           #IO.puts "I am here"
           GenServer.cast({Boss_Server,server_name},{:add_subscription_for_given_client_user,random_node_choose,node})
           GenServer.cast({Boss_Server,server_name},{:add_is_subscribed_for_given_client,random_node_choose,node})
           startValue=startValue+1;
           generate_subscriptions(list,startValue,random_number_subscriptions,server_name,node)
       end 
    end

    def random_hashTags_for_a_given_user(servername,numHashTags,list,start) do
        
        if(start<length(list)) do
            element=Enum.at(list,start-1);
            GenServer.cast({Boss_Server,servername},{:assign_hashTags_to_user,numHashTags,element})
            start=start+1
            random_hashTags_for_a_given_user(servername, numHashTags,list,start) 
        end
    end

    

end
