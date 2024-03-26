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
             cancel_film(Data,Uid);
           false ->
             <<"Invalid Header">>
         end,
  Response = #{<<"data">> =>Reply },
  ResponseBody = jiffy:encode(Response),
  Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, 
                          ResponseBody, Req),
  {ok, Req2, State}.

%helper functions 
cancel_film(#{<<"seats_count">>:=Seats,
<<"booking_id">>:=Booking_id},Uid)->
  case validate:is_client(binary_to_integer(Uid)) of 
    not_a_user->
      <<"Not a registered user">>;
    _ ->
      if
        is_integer(Seats) ->
          cancel_booking:cancel_tickets({Booking_id,Seats});
        Seats =:= <<"all">> ->
          Booking_data = mnesia:dirty_read(bookings,Booking_id),
          handle_all_case(Booking_id,Booking_data);
        true ->
          <<"Invalid input">>
      end
  end;

  cancel_film(_,_)->
    <<"invalid Inputs">>.
  
handle_all_case(Booking_id,Booking_data) ->
  case Booking_data of
    [] ->
      <<"No bookings found">>;
    [Data] ->
      Total_tickets=Data#bookings.total_tickets,
      cancel_booking:cancel_tickets({Booking_id,Total_tickets})
  end.
