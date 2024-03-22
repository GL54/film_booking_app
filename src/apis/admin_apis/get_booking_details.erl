-module(get_booking_details).
-behaviour(cowboy_handler).
-define(BACKEND_URL,"http://localhost:8000").
% The Apis
-export([init/2]).

% to get all booking in the form of csv format
init(#{method := <<"POST">>} = Req, State) ->
  Headers=maps:get(headers,Req),
  Check=maps:is_key(<<"uid">>,Headers) ,
  Reply =case Check of
          true ->
            {ok, Body, _} = cowboy_req:read_body(Req),
            #{<<"uid">> := Uid}= cowboy_req:headers(Req),
            Data=jiffy:decode(Body,[return_maps]),
            handle_booking_data(Data,Uid),
            Backend_url =?BACKEND_URL++"/bookings.csv",
            list_to_binary(Backend_url);
          false ->
            <<"Invalid Header">>
        end,
  Response = #{<<"data">> =>Reply },
  ResponseBody = jiffy:encode(Response),
  Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, 
                          ResponseBody, Req),
  {ok, Req2, State}.

  handle_booking_data(Data,Uid)->
    case validate:is_admin(binary_to_integer(Uid)) of
      not_a_user ->
        <<"Invalid id">>;
      true ->
        Date= maps:get(<<"date">>,Data),
        get_details:booking_info(Date);
      false ->
        <<"not a admin">>
    end.