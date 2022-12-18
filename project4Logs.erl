-module('project4Logs').
-author("Ammar").

%% API
-export([startServer/0, startActors/3, actors/6, createActors/6, supervisor/5]).

sendHM(AccName, PID) ->
    Choice = rand:uniform(2),
    if Choice == 1 ->
        WhatToSearch = "#Test" ++ integer_to_list(AccName),    
        {server, PID} ! {queryHM, WhatToSearch, AccName, self()};
    Choice == 2 ->
        WhatToSearch = "@user" ++ integer_to_list(AccName),
        {server, PID} ! {queryHM, WhatToSearch, AccName, self()};        
    true ->
        WhatToSearch = "",
        {server, PID} ! {queryHM, WhatToSearch, AccName, self()}   
    end
    .
actors(_PID, AccName, _NoActors, _NoRequests, 0, _Option) ->
    io:fwrite("Actor ~p Terminating~n", [AccName]);
actors(PID, AccName, NoActors, NoRequests, NR, Option) ->
    receive 
        {supSendTweet} -> 
            Choice = rand:uniform(5),
            if Choice == 1 ->
                Tweet = "#Test" ++ integer_to_list(AccName) ++ " Tweet";
            Choice == 2 ->
                Tweet = "@user" ++ integer_to_list(AccName) ++ " Tweet";
            true ->
                Tweet = "Tweet "++ integer_to_list(AccName)            
            end,
            {server, PID} ! {sendTwt, Tweet, AccName, self()},
            receive {sendTwtDone, _Tweet, AccName} ->
                io:fwrite("Tweet ~p sent by user: ~p~n", [Tweet, AccName])
            end,
            actors(PID, AccName, NoActors, NoRequests, NR, rand:uniform(4));
        {supSubsUser} -> 
            {server, PID} ! {subUser, AccName, self()},
            receive {subUserDone, AccName, OtherAccName} ->
                io:fwrite("User ~p Subscribed to user: ~p~n", [AccName, OtherAccName])
            end,
            actors(PID, AccName, NoActors, NoRequests, NR, rand:uniform(4));
        {supReTweet} -> 
            {server, PID} ! {reTwt, AccName, self()},
            receive {reTwtDone, Tweet, AccName, OtherAccName} ->
                io:fwrite("User ~p retweeted: ~p from user ~p~n", [AccName, Tweet, OtherAccName])
            end,
            actors(PID, AccName, NoActors, NoRequests, NR, rand:uniform(4));
        {supQueryHM} -> 
            sendHM(AccName, PID),            
            receive {queryHMDone, WhatToSearch, AccName} ->
                io:fwrite("User ~p searched by hashtag/mention: ~p~n", [AccName, WhatToSearch])
            end,
            actors(PID, AccName, NoActors, NoRequests, NR, rand:uniform(4));
        {recTweetServer, Tweet, Sender, SendTo} ->
            io:fwrite("Tweet ~p received without querying From user ~p By user: ~p~n",[Tweet, Sender, SendTo]),
            actors(PID, AccName, NoActors, NoRequests, NR, rand:uniform(4));
        {serverTerminated} -> 
            actors(PID, AccName, NoActors, NoRequests, 0, Option);
        {liveDisConReCon} -> 
            io:fwrite("Actor: ~p Disconneted ~n", [AccName]),
            timer:sleep(300), % 300ms delay
            io:fwrite("Actor: ~p Reconneted ~n", [AccName]),
            actors(PID, AccName, NoActors, NoRequests, NR, rand:uniform(4))
    end
    .
createActors(PID, AccName, NoActors, NoRequests, NR, Option) ->
    CID = self(),
    {server, PID} ! {createAcc, AccName, CID},  
    actors(PID, AccName, NoActors, NoRequests, NR, Option).

startActors(PID, NoActors, NoRequests) ->
    {server, PID} ! {startser, NoActors, NoRequests},
    [spawn(project4Logs, createActors, [PID, AccName, NoActors, NoRequests, NoRequests, 1]) || AccName <- lists:seq(1, NoActors)],
    done.

tweetToSubs(_SubscribedToMap, _Sender, 0, TweetDB1, _Tweet, _ActorsMap)->
    TweetDB1;
tweetToSubs(SubscribedToMap, Sender, Len, TweetDB1, Tweet, ActorsMap)->
    List = maps:get(Sender, SubscribedToMap),
    SendTo = lists:nth(Len, List),

    Check = erlang:is_map_key(SendTo, TweetDB1),
    if Check == false ->
            TweetDB2 = maps:put(SendTo, [Tweet], TweetDB1),
            OCID = maps:get(SendTo, ActorsMap),
            OCID ! {recTweetServer, Tweet, Sender, SendTo};
        true ->
            TweetDB2 = maps:put(SendTo, maps:get(SendTo, TweetDB1) ++ [Tweet], TweetDB1),
            OCID = maps:get(SendTo, ActorsMap),
            OCID ! {recTweetServer, Tweet, Sender, SendTo}
    end,
    tweetToSubs(SubscribedToMap, Sender, Len - 1, TweetDB2, Tweet, ActorsMap)
    .
sendTweetServer(_SenderID, Sender, TweetDB, SubscribedToMap, Tweet, ActorsMap) ->
        
    Check = erlang:is_map_key(Sender, TweetDB),
    if Check == false ->
        TweetDB1 = maps:put(Sender, [Tweet], TweetDB);
    true ->
        TweetDB1 = maps:put(Sender, maps:get(Sender, TweetDB) ++ [Tweet], TweetDB)
    end,
    Check1 = erlang:is_map_key(Sender, SubscribedToMap),
    if Check1 == false ->
            TweetDB1;
        true ->
            TweetDB2 = tweetToSubs(SubscribedToMap, Sender, length(maps:get(Sender, SubscribedToMap)), TweetDB1, Tweet, ActorsMap),
            TweetDB2
    end   
    .

subscribe(SubscribedToMap, AccName, NoActors) ->
    SubscribingTo = rand:uniform(NoActors),
    WhoSubscribing = AccName,
    
    
    if (SubscribingTo == AccName) ->
        subscribe(SubscribedToMap, AccName, NoActors);
    true ->
        Check = erlang:is_map_key(SubscribingTo, SubscribedToMap),
        if Check == false ->
            SubscribedToMap1 = maps:put(SubscribingTo, [WhoSubscribing], SubscribedToMap),
            {SubscribingTo, SubscribedToMap1};
        true ->
            Check2 = lists:member(WhoSubscribing, maps:get(SubscribingTo, SubscribedToMap)),
            if (Check2 /= false) ->
                {SubscribingTo, SubscribedToMap};
            true ->            
                SubscribedToMap1 = maps:put(SubscribingTo, maps:get(SubscribingTo, SubscribedToMap) ++ [WhoSubscribing], SubscribedToMap),
                {SubscribingTo, SubscribedToMap1}
            end
        end
    end
    .

retweet(TweetDB, _SubscribedToMap, _NoActors, AccName) ->
    Actors = length(maps:keys(TweetDB)),
    RetwtFrom = rand:uniform(Actors),
    RetwtTo = AccName,
    
    Check2 = erlang:is_map_key(RetwtFrom, TweetDB), 
    Check = erlang:is_map_key(RetwtTo, TweetDB),

    if (Check == false) or (Check2 == false) ->
        RandomTweet = maps:get(RetwtFrom, TweetDB),
        RT = lists:nth(rand:uniform(length(RandomTweet)), RandomTweet),
        TweetDB1 = maps:put(RetwtTo, [RT], TweetDB),
        {RT, RetwtFrom, TweetDB1};
    true ->    
        RandomTweet = maps:get(RetwtFrom, TweetDB),
        RT = lists:nth(rand:uniform(length(RandomTweet)), RandomTweet),
        TweetDB1 = maps:put(RetwtTo, maps:get(RetwtTo, TweetDB) ++ [RT], TweetDB),
        {RT, RetwtFrom, TweetDB1} 
    end
    .

matchtweets(_Tweets, 0, MatchedTweets, _WhatToSearch) ->
    MatchedTweets;
matchtweets(Tweets, TwtLen, MatchedTweets, WhatToSearch) ->
    String = lists:nth(TwtLen, Tweets),
    Check = string:find(String, WhatToSearch),
    if Check == nomatch ->
        matchtweets(Tweets, TwtLen - 1, MatchedTweets, WhatToSearch);
    true -> 
        MatchedTweets1 = MatchedTweets ++ [String],
        matchtweets(Tweets, TwtLen - 1, MatchedTweets1, WhatToSearch)
    end
    .
iterKeys(_Keys, 0, _TweetDB, MatchedTweets, _WhatToSearch) ->
    MatchedTweets;
iterKeys(Keys, KeyLen, TweetDB, MatchedTweets, WhatToSearch) ->
    Key = lists:nth(KeyLen, Keys),
    Tweets = maps:get(Key, TweetDB),
    TwtLen = length(Tweets),
    MatchedTweets1 = matchtweets(Tweets, TwtLen, MatchedTweets, WhatToSearch),
    MatchedTweets2 = iterKeys(Keys, KeyLen - 1, TweetDB, MatchedTweets1, WhatToSearch),
    MatchedTweets2
    .
queryHashtagsMentions(TweetDB, WhatToSearch) ->
    Keys = maps:keys(TweetDB),
    MatchedTweets = iterKeys(Keys, length(Keys), TweetDB, [], WhatToSearch),
    MatchedTweets,
    done.

registerAcc(ActorsMap, 0) ->
    ActorsMap;
registerAcc(ActorsMap, NoActors) ->
    receive {createAcc, AccName, CID} ->
        ActorsMap1 = maps:put(AccName, CID, ActorsMap),
        registerAcc(ActorsMap1, NoActors - 1 )
    end
    .
    
supervisor2(ActorsMap1, NoActors, AR, TermMap) ->

    X = maps:keys(TermMap),
    if length(X) == 0 ->
        io:fwrite("~nSupvisor Terminating!~n");
    true ->
        Key = lists:nth(rand:uniform(length(X)), X),
        Check = maps:is_key(Key, TermMap),
        if Check == true ->
            CID = maps:get(Key, ActorsMap1),
            TVal = maps:get(Key, TermMap),
            P = rand:uniform(100),
            DropPercent = 5, % 5% dropout chance
            if ( P >= DropPercent) ->
                if (TVal - 1) == 0 ->
                    TermMap1 = maps:remove(Key, TermMap);
                true ->
                    TermMap1 = maps:put(Key, maps:get(Key, TermMap) - 1, TermMap) 
                end,
                Option = rand:uniform(4),
                case Option of
                    1 ->  
                        CID ! {supSendTweet},
                        supervisor2(ActorsMap1, NoActors, AR - 1, TermMap1);
                    2 ->  
                        CID ! {supSubsUser},
                        supervisor2(ActorsMap1, NoActors, AR - 1, TermMap1);
                    3 ->  
                        CID ! {supReTweet},
                        supervisor2(ActorsMap1, NoActors, AR - 1, TermMap1);
                    4 ->  
                        CID ! {supQueryHM},
                        supervisor2(ActorsMap1, NoActors, AR - 1, TermMap1)
                end;
            true ->
                CID ! {liveDisConReCon},
                supervisor2(ActorsMap1, NoActors, AR, TermMap)
            end;     
        true ->
            supervisor2(ActorsMap1, NoActors, AR, TermMap)
        end
    end
    .
supervisor(ActorsMap1, NoActors, 0, AR, TermMap) ->
    supervisor2(ActorsMap1, NoActors, AR, TermMap);
supervisor(ActorsMap1, NoActors, Key, AR, TermMap) ->
    CID = maps:get(Key, ActorsMap1),
    CID ! {supSendTweet},
    supervisor(ActorsMap1, NoActors, Key - 1, AR, TermMap)
    . 
startServer() ->
    SID = self(),
    register(server, SID),
    ActorMap = #{},
    receive {startser, NoActors, NoRequests} ->
        ActorsMap1 = registerAcc(ActorMap, NoActors),
        TermList = [{NA, (NoRequests - 1)} || NA <- lists:seq(1, NoActors)],
        TermMap = maps:from_list(TermList),
        spawn(project4Logs, supervisor, [ActorsMap1, NoActors, NoActors, (NoActors - 1) * NoRequests, TermMap]),
        server(ActorsMap1, #{}, #{}, NoActors, NoRequests * NoActors)
    end
    .
terminateActors(_ActorsMap, 0) ->
    done;
terminateActors(ActorsMap, Len) ->
    CID = maps:get(Len, ActorsMap),
    CID ! {serverTerminated},
    terminateActors(ActorsMap, Len - 1)
    .
server(ActorsMap, _TweetDB, _SubscribedToMap, _NoActors, 0) ->
    terminateActors(ActorsMap, length(maps:keys(ActorsMap))),
    io:fwrite("~nServer Terminating!~n");
server(ActorsMap, TweetDB, SubscribedToMap, NoActors, NoRequests) ->
    receive 
        {sendTwt, Tweet, AccName, CID} ->
            Sender = AccName,
            TweetDB1 = sendTweetServer(maps:get(Sender, ActorsMap), Sender, TweetDB, SubscribedToMap, Tweet, ActorsMap),
            CID ! {sendTwtDone, Tweet, AccName},
            server(ActorsMap, TweetDB1, SubscribedToMap, NoActors, NoRequests - 1);
        {subUser, AccName, CID} -> 
            {OtherAccName, SubscribedToMap1} = subscribe(SubscribedToMap, AccName, NoActors),
            CID ! {subUserDone, AccName, OtherAccName}, 
            server(ActorsMap, TweetDB, SubscribedToMap1, NoActors, NoRequests - 1);
        {reTwt, AccName, CID} ->
            {Tweet, OtherAccName, TweetDB1} = retweet(TweetDB, SubscribedToMap, NoActors, AccName),
            CID ! {reTwtDone, Tweet, AccName, OtherAccName},
            server(ActorsMap, TweetDB1, SubscribedToMap, NoActors, NoRequests - 1);
        {queryHM, WhatToSearch, AccName, CID} ->
            queryHashtagsMentions(TweetDB, WhatToSearch),
            CID ! {queryHMDone, WhatToSearch, AccName},
            server(ActorsMap, TweetDB, SubscribedToMap, NoActors, NoRequests - 1)
    end

    
    
    
    % If the user is connected, deliver the above types of tweets live (without querying)
    
    .

