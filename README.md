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

### Install ruby 2.7.4 and Rails 5.2.6, make your system running under that version.

```
ruby --version #=> ruby 2.7.4
bundle exec rails version # => Rails 5.2.6
```

### Install project dependencies

Install bundler
```
bundle install
```

Install bower through NPM. Our assets are managed by bower.
```
npm install
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
SLACK_IR_CHANNEL=<incident_report_slack_channel>
SLACK_CR_CHANNEL=<change_request_slack_channel>
SECRET_KEY_BASE=x
```
### Generate Secret

```
rails secret
```

### DB Migration and Seed

```
bundle exec rake db:setup
```

### For mail interaction in Development environment, install and run Mailcatcher by running
```
gem install mailcatcher

mailcatcher
```

### Run Application
```
bundle exec rails s
```

Visit vision in `http://localhost:3000`


## Run with Docker

You can run Vision under docker, if you have problem with version compability

```
docker-compose build
docker-compose up -d

```

### DB Migration and Seed

```
docker exec -ti vision_web_1 bash

$ bundle exec rails db:setup
```

### Sign Up

Visit http://localhost:3000 and Signup using your gmail

### Approve User

```
docker exec -ti vision_web_1 bash

$ rails c
irb(main) > user = User.last
irb(main) > user.approved!
irb(main) > user.save
```

### Assign Admin

```
docker exec -ti vision_web_1 bash

$ rails c
irb(main) > user = User.last
irb(main) > user.is_admin = true
irb(main) > user.save
```


Visit http://localhost:3000

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md).

Administrate was originally written by Grace Youngblood and is now maintained by Nick Charlton. Many improvements and bugfixes were contributed by the open source community.

## LICENSE

Released under the MIT [License](LICENSE). Copyright (c) Vision.
