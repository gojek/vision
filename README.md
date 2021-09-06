# Vision

Vision was made with contributions from everyone found in git commit history.

## Architecture

Vision built with Ruby on Rails 5.2.6 and using Ruby 2.7.4, running on Heroku, requires Google Calendar API and Slack API.

To accomplish this, every environment variables are set at `.env` file.

Therefore, for running server use `bundle exec rails s` as that will read the environment variables and
run the app with it.

### Static Analysis
we're using Rubycritic with score 80, you can run `rubycritic -s 80.00 --no-browser app lib`

### Code Quality
we're using Rubocop, you can run `bundle exec rubocop`

### Code Security
we're using brakeman, but there're still some issue we can't solved due to current Rails version,
you can run with `brakeman LANG="C" LC_ALL="en_US.UTF-8" .`

### Testing
you can just use `bundle exec rspec` since environment variables are simply ignored,
as outside API call is mocked through `webmock`.
I wish it clear. Feel free to reach out for further questions.

We set code coverage minimum is 73%

## Getting Started

Vision are Change Request Management, Incident Report Management, and Access Request Management.

## Installation

1. Install ruby 2.7.4 and Rails 5.2.6, make your system running under that version.

```
ruby --version #=> ruby 2.7.4
bundle exec rails version # => Rails 5.2.6
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

In .env make sure you've check and configured:
```
DB_HOST=
DB_USERNAME=
DB_PASSWORD=
SOLR_HOST=
SOLR_PORT=
SLACK_IR_CHANNEL=<incident_report_slack_channel>
SLACK_CR_CHANNEL=<change_request_slack_channel>
```

4. Seed Database

```
bundle exec rake db:seed
```

5. For mail interaction in Development environment, install and run Mailcatcher by running
```
gem install mailcatcher

mailcatcher
```

6. Run rails
```
bundle exec rails s
```

7. Visit vision in `http://localhost:3000`

## Docker Container

You can run Vision under docker, if you have problem with version compability

```
docker-compose build
docker-compose up -d

```

Visit http://localhost:3000