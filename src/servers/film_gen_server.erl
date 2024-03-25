-module(film_gen_server).
-behaviour(gen_server).
-include("tables.hrl").
-define(ROLE,#{user=><<"user">>,admin=><<"admin">>}).
%% API
% helper functions exports
-export([next_id/1]).
% callback function exports
-export([stop/0, start_link/0,login/1,client_signup/1,admin_signup/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

stop() ->
  gen_server:call(?MODULE, stop).

start_link() ->
  initialize(),
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
% client signup
client_signup({Name,Email, Password,Address,Phone})->
  Data=#users{uuid=0,name=Name,email=Email, password=Password, address=Address, 
              phone=Phone,user_name=Email,role=maps:get(user,?ROLE)},
  gen_server:call(?MODULE,{signup,Data}).
% admin signup
admin_signup({Name,Email, Password,Address,Phone})->
  Data=#users{uuid=0,name=Name,email=Email, password=Password, address=Address, 
              phone=Phone,user_name=Email,role=maps:get(admin,?ROLE)},
  gen_server:call(?MODULE,{signup,Data}).
% client login

login({Email,Password})->
  Data={Email,Password},
  gen_server:call(?MODULE,{login,Data}).

init(_Args) ->
  process_flag(trap_exit,true),
  erlang:send_after(60000, self(), fetch_data),
  {ok, []}.

handle_call(stop, _From, State) ->
  {stop, normal, stopped, State};

% signup handling
handle_call({signup,Data}, _From, State) ->
  Email=Data#users.email,
  Reply = case is_email_exist(Email) of
            true ->
              <<"email already exist">>;
            false ->
              Password=Data#users.password,
              Hashed_password=crypto:hash(sha256,Password),
              Uid=next_id(<<"user_id">>),
              NewUser=Data#users{uuid=Uid,password=Hashed_password},
              Fun=fun()->
                      mnesia:write(NewUser)
                  end,
              mnesia:transaction(Fun),
              <<"Resigered successfully">>
          end,
  {reply, Reply, State};

% for login 
handle_call({login,{Email,Password}}, _From, State) ->
  Param=#users{email=Email,_= '_'},
  Data=mnesia:dirty_select(users,[{Param,[],['$_']}]),
  Reply = case Data of
            [] ->
              <<"Invalid email">>;
            [User]->
              Hashed_password=crypto:hash(sha256,Password),
              Cur_password=User#users.password,
              Uid=User#users.uuid,
              case Hashed_password =:= Cur_password of  
                true ->
                  Uid;
                false ->  
                  <<"Invalid password">>
              end
          end,

  {reply, Reply, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info({'EXIT', _Pid, normal}, State) ->
  {noreply, State};

handle_info(fetch_data, State) ->
  movie_reminder:maintain_notification(),
  % movie_reset:maintain_movies(),
  erlang:send_after(60000, ?MODULE, fetch_data ),
  {noreply, State};

handle_info(Message, State) ->

  error_logger:error_report([{unexpected_message, Message}]),
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

% helper functions
initialize() ->
  mnesia:stop(),
  mnesia:create_schema([node()]),
  mnesia:start(),
  mnesia:create_table(reminders, [{disc_copies,[node()]},
                                  {attributes,record_info(fields,reminders)},{type,set}]),
  mnesia:create_table(bookings, [{disc_copies,[node()]},
                                 {attributes, record_info(fields,bookings)},{type,set}]),
  mnesia:create_table(films, [{disc_copies,[node()]},
                              {attributes, record_info(fields,films)},{type,set}]),
  mnesia:create_table(users, [{disc_copies,[node()]},
                              {attributes, record_info(fields,users)},{type,set}]),
  mnesia:create_table(sequence,[{disc_copies,[node()]},
                                {attributes, record_info(fields, sequence)}, {type, set}]),
  ensure_user_sequence(),
  ensure_film_sequence(),
  ensure_booking_sequence(),
  ensure_reminders_sequence().
ensure_user_sequence()->
  catch case mnesia:dirty_read(sequence,<<"user_id">>) of
          [] ->
            User=#sequence{name = <<"user_id">>, value = 100000},
            mnesia:dirty_write(User);
          [_] ->
            ok
        end.

ensure_film_sequence()->
  catch case mnesia:dirty_read(sequence,<<"film_id">>) of
          [] ->
            Film=#sequence{name = <<"film_id">>, value = 10000},
            mnesia:dirty_write(Film);
          [_] ->
            ok
        end.

ensure_booking_sequence()->
  catch case mnesia:dirty_read(sequence,<<"booking_id">>) of
          [] ->
            Booking=#sequence{name = <<"booking_id">>, value = 10000},
            mnesia:dirty_write(Booking);
          [_] ->
            ok
        end.

ensure_reminders_sequence()->
  catch case mnesia:dirty_read(sequence,<<"reminder_id">>) of
          [] ->
            Booking=#sequence{name = <<"reminder_id">>, value = 100000},
            mnesia:dirty_write(Booking);
          [_] ->
            ok
        end.

next_id(Id) ->
  {_,NewId} = mnesia:transaction(fun () ->
                                     [{_,_,Value}] = mnesia:read(sequence, Id),
                                     NewValue = Value + 1,
                                     mnesia:write(#sequence{name = Id, value = NewValue}),
                                     NewValue
                                 end),
  NewId.

is_email_exist(Email)->
  Param=#users{email = Email ,_ = '_'},
  Data=mnesia:dirty_select(users,[{Param,[],['$_']}]),
  case Data of
    [] ->
      false;
    [_]->
      true
  end.


