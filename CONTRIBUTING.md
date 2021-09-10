# Contributing Guide

## Getting Started

Vision is a [Rails Engine][], but ships with everything needed to
contribute and test new changes.

[Rails Engine]: https://guides.rubyonrails.org/engines.html

### Opening a PR

1. Fork the repo,
2. Run `./bin/setup` to install the base dependencies and setup a local
   database,
3. Run the test suite: `bundle exec rspec`,
4. Make your changes,
5. Push your fork and open a pull request with [Pull Request Template](PULL_REQUEST_TEMPLATE.md).

A good PR will solve the smallest problem it possibly can, have good test
coverage and (where necessary) have internationalisation support.

### Running the application locally

Vision's application can be run like any Rails application:

```sh
bundle exec rails s
```

## Repository Structure

* The gem's source code lives in the `app` and `lib` subdirectories.
* The demo app is nested within `spec/example_app`.

Rails configuration files have been changed
to recognize the app in the new location,
so running the server or deploying to Heroku works normally.

With this structure, developing a typical feature looks like:

* Add tests in `spec/`

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