defmodule RegisterTest do
  use ExUnit.Case, async: true
  doctest Project4Part1


  test "Test Tweeter" do
    IO.inspect "Test the account register"
    args=["client","1","1"]
    {ip,_}=Project4Part1.LibFunctions.get_ip_address(args)
    args=args++[ip]
    tuple=Project4Part1.Node.start_client(args)
    num_users=String.to_integer(Enum.at(elem(tuple,1),1))
    num_tweets=String.to_integer(Enum.at(elem(tuple,1),2))
    server_name=String.to_atom(to_string("server@"<> Enum.at(elem(tuple,1),3)))
    list=Project4Part1.Node.get_users_list(server_name)
    IO.inspect "The user list is:"
    Enum.each(list,fn({client_name,node_name,x})-> IO.inspect client_name end)
    #Test the Query
    IO.inspect "Test the Query"
    {random_hash,hash_tweet}=Project4Part1.Node.get_hashtag(server_name)
    Enum.each(hash_tweet,fn(x)-> IO.puts "The tweet of hashtag #{inspect random_hash} includes #{inspect x}" end)

    {random_mention,mention_tweet}=Project4Part1.Node.get_mention(server_name)
    Enum.each(mention_tweet,fn(x)-> IO.puts "The tweet of mention #{inspect random_mention} includes #{inspect x}" end)

    # Test the Subscribe

    IO.inspect "Test the Subscribe"
    Enum.each(list,fn({client_name,node_name,x})->IO.puts "The subscriber of #{inspect client_name} includes "
                                                  Enum.each(Project4Part1.Node.get_sub_list(server_name,client_name,node_name),fn(x) ->IO.inspect elem(x,0) end ) end)


    IO.inspect "The user list after delete one user randomly is:"
    listdelete=Project4Part1.Node.delete_random(server_name)
    Enum.each(listdelete,fn({client_name,node_name,x})-> IO.inspect client_name end)


 #   IO.inspect sub
  end




end
