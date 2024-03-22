-module(update_booked_films).

-include("tables.hrl").

-export([datas/1,update_canceled/1,update_available_count/5]).


% for seat category , price and count
datas({seats_data,Id,Category,Field,Value})->
    Reply = case mnesia:dirty_read(films,Id) of
							[]->
								<<"invalid Id">>;
							[Film_record]->
							  Seats_data = Film_record#films.seats_data,
								update_available_count(Field,Film_record,Seats_data,Category,Value)
            end,
			Reply.

update_canceled({seats_data,Id,Category,Field,Value})->
    Reply = case mnesia:dirty_read(films,Id) of
							[]->
								<<"invalid Id">>;
							[Film_record]->
							  Seats_data = Film_record#films.seats_data,
								update_field(Field,Film_record,Seats_data,Category,Value)
            end,
			Reply.


update_available_count(<<"available_seat_count">>,Film_record,SeatsData,Category_to_update, New_data)->
Updated_data = lists:map(fun(Map) ->
                case maps:get(<<"category">>, Map) of
                    Category_to_update ->
                        Map#{<<"available_seat_count">> => New_data};
                    _ ->
                        Map
                end
            end, SeatsData),
            % Calculate the total number of seats
            TotalSeats = lists:sum([maps:get(<<"available_seat_count">>, Map) || Map <- Updated_data]),
            UpdatedFilmRecord = Film_record#films{
                seats_data = Updated_data,
                total_seats = TotalSeats
            },
            % Save the updated film record back to the database
            mnesia:dirty_write(UpdatedFilmRecord),
            <<"updated">>.




update_field(<<"available_seat_count">>,Film_record,SeatsData,Category_to_update, New_data)->
Updated_data = lists:map(fun(Map) ->
                case maps:get(<<"category">>, Map) of
                    Category_to_update ->
                        #{<<"available_seat_count">> := Cur_data}=Map,
                        Map#{<<"available_seat_count">> => Cur_data+New_data};
                    _ ->
                        Map
                end
            end, SeatsData),
            % Calculate the total number of seats
            TotalSeats = lists:sum([maps:get(<<"available_seat_count">>, Map) || Map <- Updated_data]),
            UpdatedFilmRecord = Film_record#films{
                seats_data = Updated_data,
                total_seats = TotalSeats
            },
            % Save the updated film record back to the database
            mnesia:dirty_write(UpdatedFilmRecord),
            <<"updated">>.