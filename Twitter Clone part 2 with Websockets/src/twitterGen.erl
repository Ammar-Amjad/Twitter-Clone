%%%-------------------------------------------------------------------
%% @doc twitter top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(twitterGen).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() -> supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) -> Procs = [], {ok, {{one_for_one, 10, 10}, Procs}}.

%% internal functions
