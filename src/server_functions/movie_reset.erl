-module(movie_reset).

-include("tables.hrl").

% -export([maintain_movies/0]).

% a function that will reset the movies if the current time is greater than
% the movie time 
% maintain_movies() ->
%   Data=check_movies(),
%   case Data of
%     []->
%       ok;
%     Data ->
%       Fun = fun({films,_Film_uuid,
%                   _Name,_Time,_In_system_time,Seats_data,
%                   _Total_seats,_Theater_name,_Date}=Record)->
%               update_seats(Seats_data,Record)
%             end,
%       lists:foreach(Fun,Data),
%       <<"success">>
%   end.

% % helper functions
% check_movies()->
%   Current_time = erlang:system_time(second),
%   Data = #films{in_system_time='$1', _ = '_'},
%   Guard = [{'=<','$1',Current_time}],
%   Movies=mnesia:dirty_select(films, [{Data, Guard, ['$_']}]),
%   Movies.


% update_seats(Seats_data,Film_data) ->
%   Fun = fun(#{<<"category">> :=Category,
%   <<"available_seat_count">> := Available_seats,
%   <<"total_seat_count">> := Total_seats})->
%     case Available_seats =:= Total_seats of
%       true ->
%         ok;
%       false ->
%         update_booked_films:update_available_count(<<"available_seat_count">>,
%         Film_data,Seats_data,Category,Total_seats)
%     end
%   end,
%     lists:foreach(Fun,Seats_data).