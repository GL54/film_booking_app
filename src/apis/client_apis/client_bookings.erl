-module(client_bookings).
-include("tables.hrl").

-behaviour(cowboy_handler).
% The Apis
-export([init/2]).

% for booking films by date
init(#{method := <<"GET">>} = Req, State) ->
  Headers=maps:get(headers,Req),
  Check=maps:is_key(<<"uid">>,Headers) ,
  Reply =case Check of
          true ->
            #{<<"uid">> := Uid}= cowboy_req:headers(Req),
            get_bookings(Uid);
          false ->
            <<"Invalid Header">>
        end,
  Response = #{<<"data">> =>Reply },
  ResponseBody = jiffy:encode(Response),
  Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, 
                          ResponseBody, Req),
  {ok, Req2, State}.

%helper functions 
get_bookings(Uid)->
  case validate:is_client(binary_to_integer(Uid)) of 
    not_a_user->
      <<"Not a registered user">>;
    _ ->
      [User] = mnesia:dirty_read(users,binary_to_integer(Uid)),
      Email= User#users.email,
      Query = #bookings{ email=Email,_ = '_'},
      Bookings = mnesia:dirty_select(bookings, [{Query, [], ['$_']}]),
      list_to_map(Bookings)
    end.


tuple_to_map({bookings,Id,Film_uuid,_Client_name,_Email,_Tickets,Total_price,Total_tickets}) ->
  [Movie] = mnesia:dirty_read(films,Film_uuid),
  Movie_name = Movie#films.name,
#{booking_id => Id, movie_name => Movie_name, tickets_count => Total_tickets, price =>Total_price}.

% Convert each tuple to a map
list_to_map(Data)->
  lists:map(fun tuple_to_map/1 , Data).
