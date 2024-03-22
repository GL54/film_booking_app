-module(add_details).

-include("../tables.hrl").
-export([films/2]).


films({Name,Time,Date,Theater_name},List_of_seats)->
case is_list(List_of_seats) andalso is_valid_list(List_of_seats) of
	true ->
		{Seats_data,Total_seats}=to_valid_map(List_of_seats),
		Data=#films{
			film_uuid=film_gen_server:next_id(<<"film_id">>),
			name=Name,
		  time=Time,
      in_system_time=movie_reminder:convert_to_system_time(Date,Time),
      date=Date,
			theater_name=Theater_name,
			seats_data=Seats_data,
			total_seats=Total_seats},
			mnesia:dirty_write(Data),
			<<"success">>;
  false ->
    <<"Invalid seats list">>
end.

% %%%%%%%%%%%%%%%%%%
% helper functions %
%%%%%%%%%%%%%%%%%%%%
% to check if the seats list is valid
is_valid_list([]) ->
    true;
is_valid_list([#{<<"category">> :=_Data,<<"price">> :=_Price,<<"count">> :=_Count} | Rest]) ->
  is_valid_list(Rest);

is_valid_list([_])->
	false.
% converting to a vlaid map
to_valid_map(List)->
	to_valid_map(List,[],0).
	
to_valid_map([],Map_list,Total)->
	{Map_list,Total};

to_valid_map([#{<<"category">> := Category,
								 <<"price">> :=Price,
								 <<"count">> := Count} | Rest],Map_list,Total)->
	Map=#{<<"category">> =>Category,
				<<"price">> => Price,
				<<"available_seat_count">> => Count,
				<<"total_seat_count">> => Count},
  to_valid_map(Rest,[Map | Map_list],Total+Count).
	