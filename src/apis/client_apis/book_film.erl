-module(book_film).
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
      Film_id = maps:get(<<"film_id">>,Data),
      Seats_count = maps:get(<<"seats">>,Data),
      [User]=mnesia:dirty_read(users,binary_to_integer(Uid)),
      Name=User#users.name,
      Email = User#users.email,
      client_booking:book_film(Film_id,{Name,Email,Seats_count})
    end.
