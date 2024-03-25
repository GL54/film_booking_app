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
POST :/v1/login    => to login to retrive the id {completed}

Admin
=====
POST :/admin/film => to add a film to the server {completed}
PUT  :/admin/film => to update film details {completed}
POST  :/v1/admin/booking/details => to retrive {completed}

Client
======
POST :/v1/client/signup   => to register the user {completed}
POST :/v1/client/films    => to get all films on a particular date {completed}
POST :/v1/client/booking  => to book a particular film {completed}
POST :/v1/client/cancel   => to cancel the a film booking {completed}

