-module(client_get_films).

-behaviour(cowboy_handler).
% The Apis
-export([init/2]).

% for getting todays films by date
init(#{method := <<"GET">>} = Req, State) ->
  Headers=maps:get(headers,Req),
  Check=maps:is_key(<<"uid">>,Headers) ,
  Reply =case Check of
          true ->
            #{<<"uid">> := Uid}= cowboy_req:headers(Req),
            {{Year,Month,Day},{_,_,_}}=calendar:local_time(),
            Date=integer_to_list(Year)++"-"++integer_to_list(Month)++"-"++ integer_to_list(Day),
            Map = #{<<"date">> => list_to_binary(Date)},
            get_films(Map,Uid);
          false ->
            <<"Invalid Header">>
        end,
  Response = #{<<"data">> =>Reply },
  ResponseBody = jiffy:encode(Response),
  Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, 
                          ResponseBody, Req),
  {ok, Req2, State};

% for getting films by date
init(#{method := <<"POST">>} = Req, State) ->
  Headers=maps:get(headers,Req),
  Check=maps:is_key(<<"uid">>,Headers) ,
  Reply =case Check of
          true ->
            {ok, Body, _} = cowboy_req:read_body(Req),
            #{<<"uid">> := Uid}= cowboy_req:headers(Req),
            Data=jiffy:decode(Body,[return_maps]),
            get_films(Data,Uid);
          false ->
            <<"Invalid Header">>
        end,
  Response = #{<<"data">> =>Reply },
  ResponseBody = jiffy:encode(Response),
  Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, 
                          ResponseBody, Req),
  {ok, Req2, State}.


%helper functions 
get_films(Data,Uid)->
  case validate:is_client(binary_to_integer(Uid)) of 
    not_a_user->
      <<"Not a registered user">>;
    _ ->
      Date = maps:get(<<"date">>,Data),
      Response = get_films:by_date(Date),
      list_to_map(Response)
    end.

% Function to transform each tuple into a map
tuple_to_map({films,Id,Name,Time,_,Seats_data,Seats_count,Theater_name,Date}) ->
  #{film_id => Id, name => Name, time => Time, seats_data=>Seats_data,
    date => Date,theater_name =>Theater_name,available_seats =>Seats_count}.

% Convert each tuple to a map
list_to_map(Data)->
  lists:map(fun tuple_to_map/1 , Data).