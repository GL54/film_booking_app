-module(user_login).

-behaviour(cowboy_handler).
% The Apis
-export([init/2]).

% for loggin in
init(#{method := <<"POST">>} = Req, State) ->
  {ok, Body, _} = cowboy_req:read_body(Req),
  Data=jiffy:decode(Body,[return_maps]),
  Reply=try
          login(Data)
        catch
          error:_Error->
            <<"invalid inputs">>
        end,
  Response = #{<<"uid">> =>Reply },
  ResponseBody = jiffy:encode(Response),
  Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, 
                          ResponseBody, Req),
  {ok, Req2, State}.

%helper functions 
login(Data)->
  Email= maps:get(<<"email">>,Data),
  Password= maps:get(<<"password">>,Data),

  film_gen_server:login({Email, Password}).