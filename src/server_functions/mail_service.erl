-module(mail_service).

-export([send_confirmation/2,send_cancelation/2,send_reminder/2]).

% to send confirmation updates
send_confirmation(Email,{Name,Film_name,Date,Total_amount})->
  String_name=erlang:binary_to_list(Name),
  String_email=erlang:binary_to_list(Email),
  String_film_name=erlang:binary_to_list(Film_name),
  String_date=erlang:binary_to_list(Date),
  String_amound=erlang:integer_to_list(Total_amount),

  Body="Hi "++ String_name ++",\n"++
  "Your order is confirmed." ++ "\n" ++
  "Film name : " ++ String_film_name ++ "\n" ++
  "Date : " ++ String_date ++ "\n" ++
  "Amount : " ++ String_amound ++ "\n",
  From="Movie bookings",
  Subject="Your booking is confirmed",
  send_mail(From, String_email,Subject,Body).

% function to send cancelation update
send_cancelation(Email,{Name,Refund_amount})->
  String_name=erlang:binary_to_list(Name),
  String_email=erlang:binary_to_list(Email),
  String_amound=erlang:integer_to_list(Refund_amount),

  Body="Hi "++ String_name ++",\n"++
  "Your tickets were cancelled  successfully." ++ "\n" ++
  "Amount : " ++ String_amound ++ "\n",
  From="Movie bookings",
  Subject="Your cancelation is confirmed",
  send_mail(From, String_email,Subject,Body).

% function to send reminder
send_reminder(Email,{Name,Movie_name})->
  String_name=erlang:binary_to_list(Name),
  String_email=erlang:binary_to_list(Email),
  String_movie_name=erlang:binary_to_list(Movie_name),

  Body="Hi "++ String_name ++",\n"++
  "Your movie " ++ String_movie_name ++ " will start in 30 min\n",
  From="Movie bookings",
  Subject="Your Movie is starting",
  send_mail(From, String_email,Subject,Body).

% helper function to send mail
send_mail(From,To,Subject,Body)->
  gen_smtp_client:send({"_", [To],
                        "Subject: "++Subject++"\r\nFrom: "++From++"\r\n\r\n"++Body},
                       [{relay, "smtp.gmail.com"}, 
                        {username, "test.mailsgl54@gmail.com"}, {password, "icwvyamdzfwiefsi"}]).
