# Flick Off
A small script that polls the WITS Free to air service using [gchan's](https://github.com/gchan) [wits gem](https://github.com/gchan/wits), and emails electricity price alerts for New Zealand via mailgun.
Note that you will need to know which (parent) grid exit point you are connected to.

## Setup
Make sure you have modified the `.env` file to use your own mailgun details.

Modify `.ruby-version` as you wish.

`bundle install`

## Running it
Best run in a `screen` session:

`screen bundle exec ./main.rb`

**Or** run as a background task:

`bundle exec ./main.rb --no-output &`

## Contributing
Fork and pull request. This was a very short and crude project to get something going. I won't be surprised if you do or don't want to contribute ;)
