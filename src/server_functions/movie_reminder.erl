-module(movie_reminder).
-include("tables.hrl").
-define(PREVIOUS_TIME,62167219200).
-define(STANDARD_TIME,(5*60*60)+(30*60)).

-export([set_reminder/5,maintain_notification/0,convert_to_system_time/2]).

% to set reminder to send mails before 30 min of a movie
set_reminder(Email,Name,Movie_name,Booking_id,{Time,Date})->
  System_time=convert_to_system_time(Date,Time),
  Data=#reminders{id=film_gen_server:next_id(<<"reminder_id">>),
                  email=Email,
                  name=Name,
                  booking_id=Booking_id,
                  movie_name=Movie_name,
                  time= System_time-(30*60)
                 },
  mnesia:dirty_write(Data).

% a function to maintain notificans 
maintain_notification()->
  Data=check_reminders(),
  case Data of 
    [] ->
      <<"no mails to be send">>;
    Data ->
      Fun = fun({reminders,Id,_Booking_id,Email,Name,
                 Movie_name,Time})->
                Current_time=erlang:system_time(second)+?STANDARD_TIME, 
                case Time+(15*60) >= Current_time
                     andalso Time =< Current_time of 
                  true->
                    mail_service:send_reminder(Email,{Name,Movie_name}),
                    mnesia:dirty_delete(reminders,Id);
                  false->
                    % mnesia:dirty_delete(reminders,Id)
                    ok
                end
            end,
      lists:foreach(Fun,Data),
      <<"success">>
  end.

% function to check reminders
check_reminders()->
  Current_time = erlang:system_time(second),
  Data = #reminders{time='$1', _ = '_'},
  Guard = [{'=<','$1',Current_time+?STANDARD_TIME}],
  Reminders=mnesia:dirty_select(reminders, [{Data, Guard, ['$_']}]),
  Reminders.

% to convert to system time
convert_to_system_time(DateStr, TimeStr) ->
  {Date, Time} = parse_date_time(DateStr, TimeStr),
  Time_seconds=calendar:datetime_to_gregorian_seconds({Date,Time}),
  Time_seconds -?PREVIOUS_TIME.

% to parse date form binary to a tuple
parse_date_time(DateStr, TimeStr) ->
  [Year, Month, Day] = string:tokens(binary_to_list(DateStr), "-"),
  [Hour, Minute] = string:tokens(binary_to_list(TimeStr), ":"),
  {{list_to_integer(Year), list_to_integer(Month), list_to_integer(Day)},
   { list_to_integer(Hour), list_to_integer(Minute) , 0}}.
