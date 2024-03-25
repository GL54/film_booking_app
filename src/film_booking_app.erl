%%%-------------------------------------------------------------------
%% @doc film_booking public API
%% @end
%%%-------------------------------------------------------------------
-module(film_booking_app).
-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
  film_booking_sup:start_link().

stop(_State) ->
  ok.

%% internal functions
