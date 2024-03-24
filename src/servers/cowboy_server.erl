-module(cowboy_server).
-behaviour(gen_server).

%% API
-export([stop/0, start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


stop() ->
    gen_server:call(?MODULE, stop).

start_link() ->
  start_cowboy(),

  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init(_Args) ->
    {ok, []}.

handle_call(stop, _From, State) ->
    {stop, normal, stopped, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

% helper functions
start_cowboy()->
  Dispatch = cowboy_router:compile([
                                    {'_', [
                                          % common apis
                                           {"/v1/login",user_login, []},
                                          %  client apis
                                           {"/v1/client/signup",client_signup, []},
                                           {"/v1/client/films",client_get_films, []},
                                           {"/v1/client/films/book",book_film, []},
                                           {"/v1/client/get/bookings",client_bookings, []},
                                           {"/v1/client/films/cancel",cancel_film, []},
                                          %  admin apis
                                         {"/v1/admin/film",film_handeling, []} ,
                                         {"/v1/admin/booking/details",get_booking_details, []}
                                        %  {"/v1/admin/booking/bookings.csv",cowboy_static, {priv_file, film_booking, "bookings.csv"}} 

                                         ]}
                                   ]),
  {ok, _} = cowboy:start_clear(http, [{port, 8000}], #{
                                                       env => #{dispatch => Dispatch}
                                                      }).
