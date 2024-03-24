-module(cancel_film).
-include("tables.hrl").

-behaviour(cowboy_handler).
% The Apis
-export([init/2]).

% for booking films by date
init(#{method := <<"POST">>} = Req, State) ->
  Headers=maps:get(headers,Req),
  Check=maps:is_key(<<"uid">>,Headers) ,
  Reply =case Check of
          true ->
            {ok, Body, _} = cowboy_req:read_body(Req),
            #{<<"uid">> := Uid}= cowboy_req:headers(Req),
            Data=jiffy:decode(Body,[return_maps]),
            book_film(Data,Uid);
          false ->
            <<"Invalid Header">>
        end,
  Response = #{<<"data">> =>Reply },
  ResponseBody = jiffy:encode(Response),
  Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, 
                          ResponseBody, Req),
  {ok, Req2, State}.


%helper functions 
book_film(Data,Uid)->
  case validate:is_client(binary_to_integer(Uid)) of 
    not_a_user->
      <<"Not a registered user">>;
    _ ->
      Seats = maps:get(<<"seats_count">>,Data),
      Booking_id = maps:get(<<"booking_id">>,Data),
      cancel_booking:cancel_tickets({Booking_id,Seats})
    end.
