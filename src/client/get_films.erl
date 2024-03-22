-module(get_films).
-include("tables.hrl").
-export([all/0,single_film/1,by_date/1,todays_films/0]).

all()->
	Data = #films{ _ = '_'},
	mnesia:dirty_select(films, [{Data, [], ['$_']}]).

single_film(Id)->
	mnesia:dirty_read(films, Id).

todays_films()->
	{Year,Month,Date}=erlang:date(),
	String_date= erlang:integer_to_list(Year)++"-"++
			erlang:integer_to_list(Month)++"-"++erlang:integer_to_list(Date),
	Cur_date=erlang:list_to_binary(String_date),
	by_date(Cur_date).

by_date(Date)->
	Data = #films{date=Date, _ = '_'},
	mnesia:dirty_select(films, [{Data, [], ['$_']}]).
	
