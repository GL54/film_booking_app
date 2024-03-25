-module(export_to_csv).
-export([write_bookings_to_csv/3]).

% Main function to write bookings to a CSV file
write_bookings_to_csv(Date,Bookings, FilePath) ->
  {ok, File} = file:open(FilePath, [write]), % Open the file for writing
  ok = write_csv_row(File, ["Date","Booking ID", "User ID", "Name", "Email", "Category", 
                            "Price", "Ticket Count", "Total Price", "Total Tickets"]), % Write header row
  lists:foreach(fun(Booking) -> write_booking_to_csv(Date,File, Booking) end, Bookings), % Write each booking to CSV file
  file:close(File). % Close the file

% Function to write a row to the CSV file
write_csv_row(File, Row) ->
  FormattedRow = string:join([format_field(Field) || Field <- Row], ",") ++ "\n",
  file:write(File, FormattedRow).

% Function to write a booking to the CSV file
write_booking_to_csv(Date,File, {bookings, BookingId, UserId, Name, Email, 
                                 SeatsData, TotalPrice, TotalTickets}) ->
  lists:foreach(
    fun(Seats_data) ->
        Formatted_data= format_data(Seats_data),
        Final=Formatted_data,
        String_email=erlang:binary_to_list(Email),
        String_name=erlang:binary_to_list(Name),
        write_csv_row(File, [Date,BookingId, UserId, String_name,
                             String_email, Final, TotalPrice, TotalTickets])
    end,
    SeatsData
   ).

% Function to format a field
format_field(Field) when is_map(Field) ->
  MapStr = format_map(Field),
  lists:flatten(io_lib:format("~p", [MapStr]));
format_field(Field) ->
  FieldStr = io_lib:format("~p", [Field]),
  lists:flatten(FieldStr).

% Function to format a map recursively
format_map(Map) ->
  MapStr = lists:map(
             fun({Key, Value}) ->
                 KeyStr = format_field(Key),
                 ValueStr = format_field(Value),
                 lists:flatten(io_lib:format("~s:~s", [KeyStr, ValueStr]))
             end,
             maps:to_list(Map)),
  "{" ++ string:join(MapStr, ", ") ++ "}".

% convert data to valid format
format_data(Map) ->
  MapStr = lists:map(
             fun({Key, Value}) ->
                 case erlang:is_binary(Value) of
                   true->
                     erlang:binary_to_list(Value);
                   false ->
                     erlang:integer_to_list(Value)
                 end  
             end,
             maps:to_list(Map)),
  string:join(MapStr, ", ").
