-module(test).
-include("tables.hrl").
% admin
-export([add_film/0,update_one_field/0,
        update_seat_data/0,to_csv/0]).
% client
-export([signup/0,get_all_film/0,get_one_film/0,get_film_by_date/0,
          all_bookings/0,book_film/0,cancel_film/0,
          test_confirmation/0,test_cancelation/0,test_reminder/0 ,test_set_reminder/0,admin_signup/0]).

signup()->
  film_gen_server:client_signup({<<"Jithu">>,<<"jchikku96@gmail.com">>, <<"pass">>,<<"Address">>,293974298}).

admin_signup()->
  film_gen_server:admin_signup({<<"Jithu">>,<<"jchikku96@gmail.com">>, <<"pass">>,<<"Address">>,293974298}).
  
add_film()->
    Name= <<"Ozler">>,
    Time= <<"21:10">>,
    Date= <<"2024-3-21">>,
    Theater_name= <<"PVR">>,
    Seats_data=[#{<<"category">> => <<"one">>,<<"price">> => 250,<<"count">> =>12},
    #{<<"category">> => <<"Two">>,<<"price">> => 350,<<"count">> =>12}],

    add_details:films({Name,Time,Date,Theater_name},Seats_data).

get_all_film()->
    get_films:all().

get_one_film()->
    get_films:single_film(10001).

get_film_by_date()->
    Date= <<"2024-2-29">>,
    get_films:by_date(Date).

update_one_field()->
    update_film:datas({10001,<<"time">>,<<"6:15">>}).
update_seat_data()->
    update_film:datas({seats_data,10001,<<"two">>,<<"seats_count">>,240}).

book_film()->
  client_booking:book_film(10001,{<<"Jithu">>,<<"jchikku96@gmail.com">>,20}).

cancel_film()->
  cancel_booking:cancel_tickets({10001,20}).

all_bookings()->
	Data = #bookings{ _ = '_'},
	mnesia:dirty_select(bookings, [{Data, [], ['$_']}]).

to_csv()->
  Data = all_bookings(),
  export_to_csv:write_bookings_to_csv("2024-3-22",Data,"./data.csv").

test_confirmation()->
  mail_service:send_confirmation(<<"jchikku96@gmail.com">>,{<<"Jithu">>,<<"You lie in april">>,<<"2024-3-20">>,350}).

test_cancelation()->
  mail_service:send_cancelation(<<"jchikku96@gmail.com">>,{<<"Jithu">>,350}).


test_reminder()->
  mail_service:send_reminder(<<"jchikku96@gmail.com">>,{<<"Jithu">>,<<"You lie in april">>}).

test_set_reminder()->
  movie_reminder:set_reminder(<<"jchikku96@gmail.com">>,<<"Jithu">>,<<"Ozler">>,{<<"23:59">>,<<"2024-3-21">>}).