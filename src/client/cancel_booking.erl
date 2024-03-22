-module(cancel_booking).

-include("tables.hrl").

-export([cancel_tickets/1]).

cancel_tickets({Booking_id,Ticket_count})->
case mnesia:dirty_read(bookings,Booking_id) of
  [] ->
    <<"Invalid Booking id ">>;
  [Data]->
    Film_uid=Data#bookings.film_uuid,
    Ticket_data=Data#bookings.tickets,
    Total_booked_tickets=Data#bookings.total_tickets,
    Reminder = get_reminder_time(Booking_id),
    io:format("~p",[Reminder]),
    case Total_booked_tickets >= Ticket_count andalso Reminder >= erlang:system_time(second) of
      true->
        {Total_price,Updated_data}=cancel_tickets(Film_uid,Ticket_count,Ticket_data),
        complete_canceling({Ticket_count,Data,Total_price,Updated_data}),
        <<"success">>;
      false->
        <<"Number of tickets exceeded total tickets or time has exceeded for cancelation">>
    end
  end.

cancel_tickets(Film_id,Tickets_count,Ticket_data)->
  Fun = fun(#{<<"category">> := Category,<<"price">> := Price,
                <<"ticket_count">> := Booked_ticket},
                {Ticket_count,Total_price,Total_data})->
                if
                  Booked_ticket >= Ticket_count->
                    if_booked_tickets_greater({Booked_ticket,Ticket_count,Film_id,Category,
                                                Price,Total_data,Total_price});
                  Booked_ticket<Ticket_count andalso Booked_ticket >0 ->
                    if_booked_tickets_lesser({Booked_ticket,Ticket_count,Film_id,Category,
                                                Price,Total_data,Total_price})             
                end
              end,
  {_,Total_price,Updated_data}=lists:foldl(Fun,{Tickets_count,0,[]},Ticket_data),
  {Total_price,Updated_data}.

  complete_canceling({Ticket_count,Data,Canceled_price,Updated_data})->
    Current_price = Data#bookings.total_price,
    Current_tickets = Data#bookings.total_tickets,
    Final_data=Data#bookings{total_price=Current_price-Canceled_price, 
    tickets=Updated_data,total_tickets=Current_tickets-Ticket_count},
    mnesia:dirty_write(Final_data),
    Email=Data#bookings.email,
    % Film_id=Data#bookings.film_uuid,
    [Name]=get_name(Email),
    % [Film_name]=get_film_name(Film_id),
    mail_service:send_cancelation(Email,{Name,Canceled_price}).

  get_name(Email)->
    Data = #users{email=Email,name='$1', _ = '_'},
    Name=mnesia:dirty_select(users, [{Data, [], ['$1']}]),
    io:format("----~p",[Name]),
    Name.

% get_film_name(Film_id)->
%   Data = #films{film_uuid=Film_id,name='$1', _ = '_'},
%   Film_name=mnesia:dirty_select(films, [{Data, [], ['$1']}]),
%   io:format("----~p",[Film_name]),
%   Film_name.

if_booked_tickets_greater({Booked_ticket,Ticket_count,Film_id,Category,Price,Total_data,Total_price})->
  Balance_tickets=Booked_ticket - Ticket_count,
                    update_booked_films:update_canceled({seats_data,Film_id,Category,
                    <<"available_seat_count">>,
                    Ticket_count}),
                    Data=[#{<<"category">> =>Category,<<"price">> => Price,
                                <<"ticket_count">> => Balance_tickets }|Total_data],
                    Add_price=Total_price+(Price*Ticket_count),
                    io:format("1----ticket ~p  Price ~p ~n",[Balance_tickets,Price]),
                    {0,Add_price,Data}.

if_booked_tickets_lesser({Booked_ticket,Ticket_count,Film_id,Category,Price,Total_data,Total_price})->
  Balance_tickets=  Ticket_count-Booked_ticket ,
                    update_booked_films:update_canceled({seats_data,Film_id,Category,
                                                        <<"available_seat_count">>,
                                                        Booked_ticket}),
                    _Data=[#{<<"category">> =>Category,<<"price">> => Price,
                                <<"ticket_count">> => 0 }|Total_data],
                    Add_price=Total_price+(Price*Booked_ticket),
                    io:format("2----ticket ~p  Price ~p ~n",[Balance_tickets,Price]),
                    {Balance_tickets,Add_price,Total_data}. 

get_reminder_time(Booking_id)->
  Data = #reminders{booking_id=Booking_id,time='$1', _ = '_'},
  [Time]=mnesia:dirty_select(reminders, [{Data, [], ['$1']}]),
  Time.