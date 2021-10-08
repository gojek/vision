# Contributing Guide

## Getting Started

Vision is a Ruby on Rails 5.2.6 and using Ruby 2.7.4, but ships with everything needed to
contribute and test new changes.

[Rails Engine]: https://guides.rubyonrails.org/engines.html

To accomplish this, every environment variables are set at `.env` file.

Therefore, for running server use `bundle exec rails s` as that will read the environment variables and run the app with it.

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

### Opening a PR

1. Fork the repo,
2. Run `./bin/setup` to install the base dependencies and setup a local database
3. Follow Installation in [README.md](README.md#installation)
3. Make your changes,
4. Run the test suite: `bundle exec rspec`,
5. Run the code quality: `bundle exec rubocop`
6. Run the code security: `brakeman LANG="C" LC_ALL="en_US.UTF-8" .`
5. Push your fork and open a pull request with (PR Template)[PULL_REQUEST_TEMPLATE.md].

A good PR will solve the smallest problem it possibly can, have good test
coverage and (where necessary) have internationalisation support.

### Running the application locally

Vision's application can be run like any Rails application:

```sh
bundle exec rails s
```

## Labels

Issues and PRs are split into two levels of labels, at the higher level:

* `feature`: new functionality that’s not yet implemented,
* `bug`: breakages in functionality that is implemented,
* `maintenance`: to keep up with changes around us
* `security`: controlling data access through authorisation,
* `documentation`: how to use Administrate, examples and common usage,

## Releasing

New releases (and the time period between them) is arbitrary, but usually
motivated by a new Rails release or enough bug fixes or features that
there's significant enough changes.