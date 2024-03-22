-module(film_handeling).
-behaviour(cowboy_handler).

% The Apis
-export([init/2]).

% for adding films in
init(#{method := <<"POST">>} = Req, State) ->
  Headers=maps:get(headers,Req),
  Check=maps:is_key(<<"uid">>,Headers) ,
  Reply =case Check of
          true ->
            {ok, Body, _} = cowboy_req:read_body(Req),
            #{<<"uid">> := Uid}= cowboy_req:headers(Req),
            Data=jiffy:decode(Body,[return_maps]),
            handle_add_film(Data,Uid);
          false ->
            <<"Invalid Header">>
        end,
  Response = #{<<"data">> =>Reply },
  ResponseBody = jiffy:encode(Response),
  Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, 
                          ResponseBody, Req),
  {ok, Req2, State};

% to update film data 
init(#{method := <<"PUT">>} = Req, State) ->
  Headers=maps:get(headers,Req),
  Check=maps:is_key(<<"uid">>,Headers) ,
  Reply =case Check of
          true ->
            {ok, Body, _} = cowboy_req:read_body(Req),
            #{<<"uid">> := Uid}= cowboy_req:headers(Req),
            Data=jiffy:decode(Body,[return_maps]),
            handle_update_film(Data,Uid);
          false ->
            <<"Invalid Header">>
        end,
  Response = #{<<"data">> =>Reply },
  ResponseBody = jiffy:encode(Response),
  Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, 
                          ResponseBody, Req),
  {ok, Req2, State}.

%helper functions 
% helper function to add film
handle_add_film(Data,Uid)->
  case validate:is_admin(binary_to_integer(Uid)) of
    not_a_user ->
      <<"Invalid id">>;
    true ->
      Name = maps:get(<<"film_name">>,Data),
      Time= maps:get(<<"time">>,Data),
      Date= maps:get(<<"date">>,Data),
      Seats_data= maps:get(<<"seats_data">>,Data),
      Theater_name= maps:get(<<"theater">>,Data),
      add_details:films({Name,Time,Date,Theater_name},Seats_data);
    false ->
      <<"not a admin">>
  end.

handle_update_film(Data,Uid)->
  case validate:is_admin(binary_to_integer(Uid)) of
    not_a_user ->
      <<"Invalid id">>;
    true ->
      Film_id = maps:get(<<"film_id">>,Data),
      Field= maps:get(<<"field">>,Data),
      Value= maps:get(<<"value">>,Data),
      case maps:is_key(<<"category">>,Data) of 
        true ->
          Category= maps:get(<<"category">>,Data),
          update_film:datas({seats_data,Film_id,Category,Field,Value});
        false ->
          update_film:datas({Film_id,Field,Value})
      end;
    false ->
        <<"not a admin">>
  end.
 