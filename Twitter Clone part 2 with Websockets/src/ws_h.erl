-module(ws_h).

-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).

init(Req, Opts) -> {cowboy_websocket, Req, Opts, #{idle_timeout => infinity}}.

websocket_init(State) -> {[], State}.

websocket_handle({text, Msg}, State) ->
	[ServerPID | _] = State,
	Data = jsone:decode(Msg),
	io:fwrite("~p~n", [Data]),
	Action = maps:get(<<"action">>, Data),
	case Action of
		<<"login">> -> 
			User = binary_to_list(maps:get(<<"username">>, Data)),
			ServerPID ! {login, User, self()},
			{[], State ++ [User]};

		<<"tweet">> ->
			[_, Username | _] = State,
			ServerPID ! {tweet, Username, binary_to_list(maps:get(<<"tweet">>, Data))},
			{[], State};

		<<"follow">> ->
			[_, Username | _] = State,
			ServerPID ! {follow, Username, binary_to_list(maps:get(<<"follow">>, Data))},
			{[], State};

		<<"retweet">> ->
			[_, Username | _] = State,
			ServerPID ! {
				retweet, 
				Username, 
				binary_to_list(maps:get(<<"tweetAuthor">>, Data)), 
				binary_to_list(maps:get(<<"tweet">>, Data))
			},
			{[], State};

		<<"search">> ->
			[_, Username | _] = State,
			ServerPID ! {
				search, 
				Username, 
				binary_to_list(maps:get(<<"query">>, Data))
			},
			{[], State}
	end;

websocket_handle(_Data, State) -> {[], State}.

websocket_info({timeout, _Ref, Msg}, State) -> {[{text, Msg}], State};
websocket_info(_Info, State) -> {[], State}.