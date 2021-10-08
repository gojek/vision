# Vision

Vision was made with contributions from everyone found in git commit history.

## Getting Started

Vision is a tool that will help yout to manage change request, incident report and access/resource request in your organization.


## Installation

### Install ruby 2.7.4 and Rails 5.2.6

make your system running under that version.

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
bower install
```

### Generate Secret

```
rails secret
```

and put in `.env` for key `SECRET_KEY_BASE`

### Configuration
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
4. Generate Secret

### DB Migration and Seed

```
bundle exec rake db:setup
```

### For mail interaction in Development environment, install and run Mailcatcher by running
```
gem install mailcatcher

mailcatcher
```

### Approvers

Follow set Approver (here)[#5-approvers]

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

### Approvers

Follow set Approver (here)[#5-approvers]

### Run Application

Visit http://localhost:3000


## Prerequisites

Vision application require some tools to run:

### 1. Google Oauth 2.0

  - Visit `https://console.cloud.google.com/apis/credentials`
  - Create Credentials -> OAuth client ID
  - Choose Web Application as Application Type
  - Fill `Authorized JavaScript origins` with your host url (e.g example.com)
  - Fill `Authorized redirect URIs` with your host and append `users/auth/google_oauth2/callback` (e.g example.com/users/auth/google_oauth2/callback)
  - Store your Client ID and Client Secret for next Vision setup in Environment Variable

### 2. Slack

- Visit `https://api.slack.com/apps`
- Create New App if you don't have app
- Go to menu `OAuth & Permissions`
- Go to section `Scopes` and Add an OAuth Scope
- Add `channels:history` scope for `User Token Scopes`
- Add `channels:read` scope for `User Token Scopes`
- Add `channels:write` scope for `User Token Scopes`
- Add `chat:write` scope for `User Token Scopes`
- Add `users:read` scope for `User Token Scopes`
- Add `users:read.email` scope for `User Token Scopes`
- Copy `User OAuth Token` value for `SLACK_API_TOKEN` environment variable
- Go to menu `Basic Information`
- Go to `App Credentials`
- Copy `Verification Token` value for `SLACK_VERIFICATION_TOKEN` environment variable
- Create channel for change request for `SLACK_CR_CHANNEL` environment variable
- Create channel for incident report `SLACK_IR_CHANNEL` environment variable
- Go to menu `Interactivity & Shortcuts`
- Fill Request URL with format `{APP_HOST}/api/change_requests/action`

### 3. JIRA

- Create your JIRA account if you don't have [here](https://www.atlassian.com/try/cloud/signup?bundle=jira-software)
- Put your Jira site url as value of `JIRA_URL` for environment variable
- Put your email as value of `JIRA_USERNAME` for environment variable
- Create API Token on Security Atlassian (`https://id.atlassian.com/manage-profile/security/api-tokens`)
- Put API Token as `JIRA_PASSWORD` for environment variable

### 4. Google Calendar

- Enable Google Calendar API
- Visit (https://calendar.google.com/calendar/u/0/r/settings)(https://calendar.google.com/calendar/u/0/r/settings)
- Go to section `Settings for my calendars`
- Go to menu `Share with specific people` and invite the users with permission `Make changes to events`
- Go to menu `Integrate calendar`
- Copy `Calendar ID` value for `DEPLOY_CALENDAR_ID` environment variable

for more info follow [here](https://developers.google.com/calendar/api/guides/auth)

### 5. Approvers

Vision required 2 Approvers, you can create with the seed:

```sh
rails vision:approver:seed name="Approver" email="approver@gmail.com"
```

## Deploy

In this example we use will [Heroku](heroku.com) to deploy vision.

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

## LICENSE

Released under the Apache 2.0 [License](LICENSE). Copyright (c) 2021 Vision.

## Contributing

Please see [CONTRIBUTING.md](CONTRIBUTING.md).

Vision was originally written by Midtrans Developer and is now maintained by GO-JEK Tech. Many improvements and bugfixes were contributed by the open source community.
