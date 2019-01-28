# Vision

Vision was made with contributions from everyone found in git commit history.

## Architecture

Vision built with Ruby on Rails, running on Heroku, requires Google Contacts and Calendar API.

To accomplish this, every environment variables are set at `.env` file.

Therefore, for running server use `foreman start` as that will read the environment variables and
run the app with it.

For testing, you can just use `bundle exec rspec` since environment variables are simply ignored,
as outside API call is mocked through `webmock`.

I wish it clear. Feel free to reach out for further questions.

## Getting Started

1. Install ruby

2. Install bower through NPM. Our assets are managed by bower.

3. Install project dependencies

```
bundle install
```

Then install bower dependencies:

```
bower install
```

4. Run rails

```
foreman start
```

5. Visit vision in `localhost:3000`


6. For mail interaction in Development environment, install and run Mailcatcher by running

```
gem install mailcatcher

mailcatcher

```

7. Slack notification configuration. Set environment variable to:
```
SLACK_IR_CHANNEL=<incident_report_slack_channel>
SLACK_CR_CHANNEL=<change_request_slack_channel>
```

If variable value of slack channel's name is not found in current registered API key, rails raise error before server is started.