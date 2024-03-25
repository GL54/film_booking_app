-module(update_film).

-include("../tables.hrl").

% Exports
-export([datas/1]).

% for seat category , price and count
datas({seats_data,Id,Category,Field,Value})->
  Reply = case mnesia:dirty_read(films,Id) of
            []->
              <<"invalid film Id">>;
            [Film_record]->
              Seats_data = Film_record#films.seats_data,
              update_seats_data(Field,Film_record,Seats_data,Category,Value)
          end,
  Reply;

datas({Id,Field,Value})->
  Reply = case mnesia:dirty_read(films,Id) of
            []->
              <<"invalid film Id">>;
            [Data]->
              update_field(Data,Field,Value)
          end,
  Reply.

% Helper functions
% to update a specific field
update_field(Data,<<"name">>,Value)->
  Update=Data#films{name=Value},
  mnesia:dirty_write(Update),
  <<"success">>;

update_field(Data,<<"time">>,Value)->
  Update=Data#films{time=Value},
  mnesia:dirty_write(Update),
  <<"success">>;

update_field(Data,<<"theater_name">>,Value)->
  Update=Data#films{theater_name=Value},
  mnesia:dirty_write(Update),
  <<"success">>;

update_field(Data,<<"date">>,Value)->
  Update=Data#films{date=Value},
  mnesia:dirty_write(Update),
  <<"success">>;

update_field(_Data,_,_Value)->
  <<"Invalid field">>.

% to update seat datas
update_seats_data(<<"seats_count">>,Film_record,SeatsData,Category_to_update, New_data)->
  Updated_data = lists:map(fun(Map) ->
                               case maps:get(<<"category">>, Map) of
                                 Category_to_update ->
                                   Map#{<<"total_seat_count">> => New_data};
                                 _ ->
                                   Map
                               end
                           end, SeatsData),
  % Calculate the total number of seats
  _TotalSeats = lists:sum([maps:get(<<"total_seat_count">>, Map) || Map <- Updated_data]),
  UpdatedFilmRecord = Film_record#films{
                        seats_data = Updated_data
                       },
  % Save the updated film record back to the database
  mnesia:dirty_write(UpdatedFilmRecord),
  <<"updated">>;

update_seats_data(<<"price">>,Film_record,SeatsData,Category_to_update, New_data)->
  Updated_data = lists:map(fun(Map) ->
                               case maps:get(<<"category">>, Map) of
                                 Category_to_update ->
                                   Map#{<<"price">> => New_data};
                                 _ ->
                                   Map
                               end
                           end, SeatsData),
  % Calculate the total number of seats
  UpdatedFilmRecord = Film_record#films{
                        seats_data = Updated_data
                       },
  % Save the updated film record back to the database
  mnesia:dirty_write(UpdatedFilmRecord),
  <<"updated">>;

update_seats_data(_,_Film_record,_SeatsData,_Category_to_update,_New_data)->
  <<"invalid Field">>.


