-module(validate).
-include("tables.hrl").

-define(ROLE,#{user=><<"user">>,admin=><<"admin">>}).
-export([is_admin/1, is_client/1]).

is_admin(Id)->
  User = mnesia:dirty_read(users,Id),
  io:format("----- the user is ~p",[User]),
  case User of 
    [] ->
      not_a_user;
    [Data]->
      Data#users.role =:= maps:get(admin,?ROLE)
  end.
    
is_client(Id)->
  User = mnesia:dirty_read(users,Id),
  case User of 
    [] ->
      not_a_user;
    [Data]->
      Data#users.role =:= maps:get(user,?ROLE)
  end.

