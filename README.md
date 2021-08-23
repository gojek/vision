# Vision

Vision was made with contributions from everyone found in git commit history.

## Architecture

Vision built with Ruby on Rails 4.2.10 and using Ruby 2.4.5, running on Heroku, requires Google Calendar API and Slack API.

To accomplish this, every environment variables are set at `.env` file.

Therefore, for running server use `bundle exec rails s` as that will read the environment variables and
run the app with it.

For testing, you can just use `bundle exec rspec` since environment variables are simply ignored,
as outside API call is mocked through `webmock`.

I wish it clear. Feel free to reach out for further questions.

## Getting Started

Vision are Change Request Management, Incident Report Management, and Access Request Management.

## Installation

1. Install ruby 2.4.5 and Rails 4.2.10, make your system running under that version.

```
ruby --version #=> ruby 2.4.5 
bundle exec rails version # => Rails 4.2.10
```

2. Install project dependencies

Install bundler
```
bundle install
```

Install bower through NPM. Our assets are managed by bower.
```
npm install
```

Install Apache Solr, make sure you can access under port 8983 (http://localhost:8983)
```
brew install solr
solr create_core -c development
solr create_core -c test
```

3. Configuration
```
cp .env.example .env # for development environment
cp .env.example .env.test # for test environment
cp config/database.example.yml config/database.yml
```

In .env
```
SLACK_IR_CHANNEL=<incident_report_slack_channel>
SLACK_CR_CHANNEL=<change_request_slack_channel>
```

4. Seed Database

```
bundle exec rake db:seed
```

5. Run rails
```
bundle exec rails s
```

6. Visit vision in `localhost:3000`

7. For mail interaction in Development environment, install and run Mailcatcher by running
```
gem install mailcatcher

mailcatcher
```
