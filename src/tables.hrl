
-record(sequence,{name, 
                  value}).

-record(users,{uuid=0,
               name,
               email,
               password,
               address,
               role,
               phone,
               user_name}).


-record(films,{film_uuid,
               name,
               time,
               in_system_time,
               seats_data,
               total_seats=0,
               theater_name,
               date
               }).

-record(bookings,{id,
                 film_uuid,
                 client_name,
                 email,
                 tickets,
                 total_price,
                 total_tickets
                 }).

-record(reminders,{id,
                  booking_id,
                  email,
                  name,
                  movie_name,
                  time}).




