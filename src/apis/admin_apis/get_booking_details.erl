-module(get_booking_details).
-behaviour(cowboy_handler).% The Apis
-export([init/2]).

% to get all booking in the form of csv format
% init(#{method := <<"GET">>} = Req, State) ->
%   Headers=maps:get(headers,Req),
%   case maps:is_key(<<"uid">>,Headers)  of
%           true ->
%           #{<<"uid">> := Uid}= cowboy_req:headers(Req),
%           send_file(Req,State,Uid,data);
%           false ->
%             Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>,
%             <<"content-disposition">> => <<"attachment; filename=\"bookings.csv\"">>}, 
%             <<"Invalid Header">>, Req),
%             {ok, Req2, State}
%         end;
% to get all booking in the form of csv format
init(#{method := <<"POST">>} = Req, State) ->
  Headers=maps:get(headers,Req),
  Check=maps:is_key(<<"uid">>,Headers) ,
  case Check of
          true ->
            {ok, Body, _} = cowboy_req:read_body(Req),
            #{<<"uid">> := Uid}= cowboy_req:headers(Req),
            Data=jiffy:decode(Body,[return_maps]),
            handle_booking_data(Req,State,Data,Uid);
          false ->
            Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>,
            <<"content-disposition">> => <<"attachment; filename=\"bookings.csv\"">>}, 
            <<"Invalid Header">>, Req),
            {ok, Req2, State}
        end.

  handle_booking_data(Req,State,Data,Uid)->
    case validate:is_admin(binary_to_integer(Uid)) of
      not_a_user ->
      Response1 = cowboy_req:reply(401, #{<<"content-type">> => <<"text/csv">>,
      <<"content-disposition">> => <<"attachment; filename=\"bookings.csv\"">>}, 
      <<"Invalid id">>, Req),
      {ok, Response1, State};
      true ->
        Date= maps:get(<<"date">>,Data),
        Booking_status=get_details:booking_info(Date),
        send_file(Req,State,Uid,Booking_status);
      false ->
      Response1 = cowboy_req:reply(401, #{<<"content-type">> => <<"text/csv">>}, 
      <<"not a admin">>, Req),
      {ok, Response1, State}
    end.

  send_file(Req,State,Uid,Data)->
    case validate:is_admin(binary_to_integer(Uid)) of
      true ->
            case is_binary(Data) of 
              true ->
                 Res = cowboy_req:reply(200, #{<<"content-type">> => <<"text/csv">>,
                <<"content-disposition">> =><<"attachment;filename=\"bookings.csv\"">>},Data,Req),
            {ok, Res, State};
              false ->
            {ok, FileContents} = file:read_file("./priv/bookings.csv"),
            Headers = #{<<"content-type">> =><<"application/octet-stream">>,
                         <<"content-disposition">> =><<"attachment;filename=\"bookings.csv\"">>},
            Response = cowboy_req:reply(200, Headers, FileContents,Req),
            {ok, Response, State}
          end;
        _ ->
            Response2 = cowboy_req:reply(401, #{<<"content-type">> => <<"text/csv">>,
            <<"content-disposition">> => <<"attachment; filename=\"bookings.csv\"">>}, 
          <<"Unauthorized">>, Req),
            {ok, Response2, State}
    end.