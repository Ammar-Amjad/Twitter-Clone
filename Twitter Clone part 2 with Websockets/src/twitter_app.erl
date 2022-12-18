%%%-------------------------------------------------------------------
%% @doc twitter public API
%% @end
%%%-------------------------------------------------------------------

-module(twitter_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    ServerID = spawn_link(twitter_server, start, [{#{}, #{}}]),
    Dispatch = cowboy_router:compile([
		{'_', [
			{"/", cowboy_static, {priv_file, twitter, "index.html"}}, %  front end
			{"/style.css", cowboy_static, {priv_file, twitter, "style.css"}}, % front end
			{"/websocket", ws_h, [ServerID]}, % web socket
			{"/static/[...]", cowboy_static, {priv_dir, twitter, "static"}} % static content and javascript file
		]}
	]),
	{ok, _} = cowboy:start_clear(http, [{port, 8080}], #{env => #{dispatch => Dispatch}}), % open socket at localhost port 8080
	twitterGen:start_link().

stop(_State) ->
    ok.

%% internal functions
