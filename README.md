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

## Prerequisites

Vision application require some tools to run:

1. Google Oauth 2.0

Please create `OAuth 2.0 Client IDs`

  - Visit `https://console.cloud.google.com/apis/credentials`
  - Create Credentials -> OAuth client ID
  - Choose Web Application as Application Type
  - Fill `Authorized JavaScript origins` with your host url (e.g example.com)
  - Fill `Authorized redirect URIs` with your host and append `users/auth/google_oauth2/callback` (e.g example.com/users/auth/google_oauth2/callback)
  - Store your Client ID and Client Secret for next Vision setup in Environment Variable


2. Slack
3. JIRA

4. 2 Approvers Person

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

## Run with Docker

You can run Vision under docker, if you have problem with version compability

```
docker-compose build
docker-compose up -d

```

### DB Migration and Seed

```
docker exec -ti vision_web_1 bash

$ bundle exec rake db:create
$ bundle exec rake db:migrate
$ bundle exec rake db:seed
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

## Deploy

Currently we provide deploy to [Heroku](heroku.com)

1. Prepare [prerequisites](#Prerequisites) (Google API, Slack, and Jira)
2. Create Heroku Application with stack `container`
3. Add adds-on `Heroku Postgres` in `Resources Menu`
4. Create `Config Vars` in `Settings` menu

Key | Value | Description
--------- | ----------- | -------
`APP_HOST` | http://heroku-app.herokuapp.com | Required, You can fill with heroku app url
`APPROVER_EMAIL` | | Required, Approver email, you can get from prerequisites
`DB_HOST` | localhost | Required, you can get from Heroku Postgres adds-on
`DB_NAME` | vision | Required, you can get from Heroku Postgres adds-on
`DB_USERNAME` | postgres | Required, you can get from Heroku Postgres adds-on
`DB_PASSWORD` |  | Required, you can get from Heroku Postgres adds-on
`DEPLOY_CALENDAR_ID` | visiongojek@gmail.com | Required, You can get Google Calender ID [here](https://docs.simplecalendar.io/find-google-calendar-id/)
`ENTITY_SOURCES` | | Required, you can have multiple source combine with comma. (e.g org1,org2)
`GOOGLE_API_KEY` | | Required, you can get from prerequisites step
`GOOGLE_API_SECRET` | | Required, you can get from prerequisites step
`INCIDENT_LEVEL_GUIDELINE` | | 
`JIRA_USERNAME` | | Required, you can get from prerequisites step
`JIRA_PASSWORD` | | Required, you can get from prerequisites step
`JIRA_URL` | | Required, you can get from prerequisites step
`MAIL_ADDRESS` | | Required
`MAIL_AUTHENTICATION` | | Required
`MAIL_DOMAIN` | | Required
`MAIL_USERNAME` | | Required
`MAIL_PASSWORD` | | Required
`MAIL_PORT` | | Required
`RAILS_ENV` | staging | Required
`SECRET_KEY_BASE` | xx | Required, you can generate with `rails secret`
`SLACK_API_TOKEN` | | Required, you can get from prerequisites step
`SLACK_VERIFICATION_TOKEN` | | Required, you can get from prerequisites step
`SLACK_CR_CHANNEL` | | Slack channel Change Request
`SLACK_IR_CHANNEL` | | Slack channel Incident Report
`VALID_EMAIL` | gmail.com | you can fill with your domain google business suite


4. Push docker image to Heroku container registry
```
heroku container:login
heroku container:push web -a {heroku-app}
```

5. Deploy
```
heroku container:release web -a {heroku-app}
```