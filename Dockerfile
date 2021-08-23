# Compile gems, and precompile assets
FROM ruby:2.4.5-alpine AS application

RUN apk add --no-cache git bash libc6-compat build-base postgresql-dev postgresql-client linux-headers nodejs npm tzdata

RUN mkdir -p /app
WORKDIR /app
COPY Gemfile* ./
COPY package.json package-lock.json ./
RUN npm install

COPY config/database.example.yml config/database.yml

RUN if [[ "$RAILS_ENV" == "production" ]]; then bundle install --without development test; else bundle install; fi

COPY ./ ./

EXPOSE 3000

CMD bundle exec puma -C config/puma.rb