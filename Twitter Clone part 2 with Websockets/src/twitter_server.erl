-module(twitter_server).

-export([start/1]).

start(State) ->
  {UserMapping, TweetDB} = State,
  lager:info("Here's the map: ~p | ~p", [UserMapping, TweetDB]),
  receive
    {login, User, CID} ->
      lager:info("User: ~p has logged-in.~n",[User]),
      NewState = twitter_core:registerUser(State, User, CID),
      start(NewState);

    {tweet, User, Tweet} ->
      lager:info("User: ~s has tweeted: ~s", [User, Tweet]),
      NewState = twitter_core:tweet(State, User, User, Tweet),
      start(NewState);

    {follow, User, FollowUser} ->
      lager:info("~s has subscribed to follow ~s", [User, FollowUser]),
      NewState = twitter_core:follow(State, User, FollowUser),
      start(NewState);
    
    {retweet, User, TweetAuthor, Tweet} ->
      lager:info("~s has retweeted tweet: ~p by author: ~s", [User, TweetAuthor, Tweet]),
      NewState = twitter_core:tweet(State, User, TweetAuthor, Tweet),
      start(NewState);

    {search, User, Query} ->
      twitter_core:query(State, User, Query),
      start(State)

  end.
