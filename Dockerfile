FROM ruby:4.0

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

WORKDIR /app

COPY Gemfile .
COPY Gemfile.lock .

RUN bundle install -j 8

COPY . /app

ENTRYPOINT ["./bin/cli"]
