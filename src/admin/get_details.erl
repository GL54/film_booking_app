-module(get_details).

-include("tables.hrl").

-export([booking_info/1]).

booking_info(Date) ->
  Data = film_id(Date),
  case Data of
  [] ->
    <<"no movies on this date">>;
  Film_ids ->
  Bookings=lists:foldl(
    fun(Film_id,List)->
      Query = #bookings{film_uuid=Film_id ,_= '_'},
      Select=mnesia:dirty_select(bookings, [{Query, [], ['$_']}]),
      is_data(Select,List)
    end ,[],Film_ids),
    case Bookings of 
      []->
        <<"no bookings">>;
      Bookings ->
        File_path="./priv/bookings.csv",
        Date_to_string=erlang:binary_to_list(Date),
        export_to_csv:write_bookings_to_csv(Date_to_string,Bookings, File_path)
    end
end.

film_id(Date)->
  Data = #films{date=Date,film_uuid='$1', _ = '_'},
  Film_id=mnesia:dirty_select(films, [{Data, [], ['$1']}]),
  Film_id.

is_data(Select,List) ->
  case Select of
    []->
      [];
    Data->
      convert_to_list(Data,List)
  end.

convert_to_list([],List) ->
  List;
convert_to_list([Data|Tail],List) ->
  convert_to_list(Tail,[Data|List]).