-module(get_details).

-include("tables.hrl").

-export([booking_info/1]).

booking_info(Date) ->
  Film_id = film_id(Date),
  Data = #bookings{ film_uuid=Film_id ,_= '_'},
	Bookings=mnesia:dirty_select(bookings, [{Data, [], ['$_']}]),
  File_path="./bookings.csv",
  Date_to_string=erlang:binary_to_list(Date),
  export_to_csv:write_bookings_to_csv(Date_to_string,Bookings, File_path).

film_id(Date)->
  Data = #films{date=Date,film_uuid='$1', _ = '_'},
  [Film_id]=mnesia:dirty_select(films, [{Data, [], ['$1']}]),
  io:format("----~p",[Film_id]),
  Film_id.