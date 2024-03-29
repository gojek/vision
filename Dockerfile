# Compile gems, and precompile assets
FROM ruby:2.7.3-alpine AS application

RUN apk add --no-cache git bash libc6-compat build-base postgresql-dev postgresql-client linux-headers nodejs npm tzdata

RUN mkdir -p /app
WORKDIR /app

COPY package.json package-lock.json .bowerrc bower.json ./
RUN npm install
RUN ./node_modules/bower/bin/bower install

COPY Gemfile* ./
COPY config/database.example.yml config/database.yml

# enable jemalloc
RUN wget -O - https://github.com/jemalloc/jemalloc/releases/download/5.2.1/jemalloc-5.2.1.tar.bz2 | tar -xj && \
    cd jemalloc-5.2.1 && \
    ./configure && \
    make && \
    make install
ENV LD_PRELOAD=/usr/local/lib/libjemalloc.so.2

RUN gem install bundler:1.17.3

RUN if [[ "$RAILS_ENV" == "production" ]]; then bundle install --without development test; else bundle install; fi

COPY ./ ./

RUN rails assets:precompile

EXPOSE 3000

CMD bundle exec puma -C config/puma.rb