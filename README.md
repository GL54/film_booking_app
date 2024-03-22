film_booking
=====

An OTP application

Build
-----

    $ rebar3 compile

Endpoints
---------
Common 
======
POST :/v1/login    => to login to retrive the id

Admin
=====
POST :/admin/film => to add a film to the server
PUT  :/admin/film => to update film details
GET  :/admin/data/bookings => to retrive 

Client
======
POST :/v1/client/signup   => to register the user
POST :/v1/client/films    => to get all films on a particular date 
POST :/v1/client/booking  => to book a particular film
POST :/v1/client/cancel   => to cancel the a film booking

