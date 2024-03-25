% for a table to maintain id's of the some tables
-record(sequence,{name, 
                  value}).

% to maintain user information
-record(users,{uuid=0,
               name,
               email,
               password,
               address,
               role,
               phone,
               user_name}).

% to maintain films information
-record(films,{film_uuid,
               name,
               time,
               in_system_time,
               seats_data,
               total_seats=0,
               theater_name,
               date
               }).

% to maintain booking information
-record(bookings,{id,
                 film_uuid,
                 client_name,
                 email,
                 tickets,
                 total_price,
                 total_tickets
                 }).

% to maintain reminders information
-record(reminders,{id,
                  booking_id,
                  email,
                  name,
                  movie_name,
                  time}).




