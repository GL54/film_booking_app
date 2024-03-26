-module(client_booking).
-include("tables.hrl").
-define(STANDARD_TIME,(5*60*60)+(30*60)).

-export([book_film/2]).

book_film(Film_id,{Name,Email,Tickets_count}) ->
  case mnesia:dirty_read(films,Film_id) of
    []->
      <<"Invalid Film Id">>;
    [Data]->
      Total_seats=Data#films.total_seats,
      Seats_data=Data#films.seats_data,
      Film_time=Data#films.time,
      In_Sys_Time=Data#films.in_system_time,
      case Total_seats >= Tickets_count andalso
           In_Sys_Time >= (erlang:system_time(second)+?STANDARD_TIME) of
        true->
          {Total_price,Booking_data}=book_tickets(Film_id,Tickets_count,Seats_data),
          complete_booking({Film_id,Name,Email,Tickets_count,Total_price,Booking_data,Film_time});
        false->
          <<"Booking is closed or invalid ticket count">>
      end
  end.

book_tickets(Id,Tickets_count,Seat_data) ->
  {_,Total_price, Total_data} = 
  lists:foldl(fun(#{<<"category">> := Category,<<"price">> := Price,
                    <<"available_seat_count">> := Seats}
                  ,{Tickets,Total_price,Total_data}) ->
                  if 
                    Seats =:= 0 ->
                      {Tickets,Total_price,Total_data};
                    Tickets =:= 0 ->
                      {Tickets,Total_price,Total_data};
                    Seats>=Tickets ->
                      if_seats_greater_than_tickets({Category,Seats,Tickets,Id,Price,
                                                     Total_data,Total_price});
                    Seats<Tickets andalso Seats >0 ->
                      if_seats_less_than_tickets({Category,Seats,Tickets,Id,Price,
                                                  Total_data,Total_price})
                  end
              end, {Tickets_count,0,[]},
              Seat_data),
  {Total_price,Total_data}.

complete_booking({Film_id,
                  Name,Email,Tickets_count,
                  Total_price,Booking_data,Film_time})->
  Booking_id=film_gen_server:next_id(<<"booking_id">>),
  Data=#bookings{
          id=Booking_id,
          film_uuid=Film_id,
          client_name=Name,
          email=Email,
          tickets=Booking_data,
          total_price=Total_price,
          total_tickets=Tickets_count},
  mnesia:dirty_write(Data),
  {Film_name,Film_date}=get_film_data(Film_id),
  mail_service:send_confirmation(Email,{Name,Film_name,Film_date,Total_price}),
  movie_reminder:set_reminder(Email,Name,Film_name,Booking_id,{Film_time,Film_date}).


get_film_data(Film_id)->
  [Film]=mnesia:dirty_read(films, Film_id),
  Film_name=Film#films.name,
  Film_date=Film#films.date,
  {Film_name,Film_date}.

if_seats_greater_than_tickets({Category,Seats,Tickets,Id,Price,
                               Total_data,Total_price})->
  Category_seats=Seats-Tickets,
  update_booked_films:datas({seats_data,Id,Category,<<"available_seat_count">>,Category_seats}),
  Data=[#{<<"category">> =>Category,<<"price">> => Price,
          <<"ticket_count">> =>Tickets}|Total_data],
  Category_total=Total_price+(Tickets*Price),
  {0,Category_total,Data}.

if_seats_less_than_tickets({Category,Seats,Tickets,Id,Price,
                            Total_data,Total_price})->
  update_booked_films:datas({seats_data,Id,Category,<<"available_seat_count">>,0}),
  Category_seats=Tickets-Seats,
  Category_total=Total_price+(Seats*Price),
  Data=[#{<<"category">> =>Category,<<"price">> => Price,
          <<"ticket_count">> =>Seats}|Total_data],
  {Category_seats,Category_total,Data}.
