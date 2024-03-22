%%%-------------------------------------------------------------------
%% @doc film_booking top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(film_booking_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    SupFlags = #{strategy => one_for_all,
                 intensity => 10,
                 period => 60},
    ChildSpecs =  [#{
                id => film_gen_server,
                start => {film_gen_server, start_link, []},
                restart => permanent, % permanent | transient | temporary
                shutdown => 2000,
                type => worker, % worker | supervisor
                modules => [film_gen_server]
               },
               #{
                id => cowboy_server,
                start => {cowboy_server, start_link, []},
                restart => permanent, % permanent | transient | temporary
                shutdown => 2000,
                type => worker, % worker | supervisor
                modules => [cowboy_server]
               }
             ],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
