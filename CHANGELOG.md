Change Log
==========

0.2.2
-----

- Fixed bug causing Instagram and Tumblr importing to silently fail if a query
  does not begin with a '#' or '@' symbol.
- Twitter import now silently fails if Twitter returns a specific kind of
  error.

0.2.1
-----

- Added error to the import rake task telling the user if there are no search
  terms configured.

0.2.0
-----

- Added rake tasks allowing photos to be imported from the command line and
  from cron jobs.

0.1.1
-----

- Added a basic install generator that copies a config file to the app.

0.1.0
-----

- Initial release.