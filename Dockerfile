FROM ruby:2.7.2-alpine AS base

# Set a variable for the install location.
ARG RAILS_ROOT=/usr/src/app
# Set Rails environment.
ENV RAILS_ENV production
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"

# Make the directory and set as working.
RUN mkdir -p $RAILS_ROOT
WORKDIR $RAILS_ROOT

ARG BUILD_PACKAGES="build-base curl-dev git"
ARG DEV_PACKAGES="postgresql-dev sqlite-libs sqlite-dev yaml-dev zlib-dev nodejs yarn"
ARG RUBY_PACKAGES="tzdata"
ARG STREAMING_PACKAGE="gnupg psmisc chromium ffmpeg  make g++ libgbm-dev ffmpeg gconf-service libasound2 libatk1.0-0 libc6 libcairo2 \
                                        libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 \
                                        libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 \
                                        libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 \
                                        libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 \
                                        libxtst6 ca-certificates fonts-liberation libappindicator1  libnss3 \
                                        lsb-release xdg-utils wget xvfb fonts-noto \
                                        dbus-x11 libasound2 fluxbox  libasound2-plugins alsa-utils  alsa-oss pulseaudio pulseaudio-utils"

# Install app dependencies.
RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES $STREAMING_PACKAGE

COPY Gemfile* ./
COPY Gemfile Gemfile.lock $RAILS_ROOT/

RUN bundle config --global frozen 1 \
    && bundle install --deployment --without development:test:assets -j4 --path=vendor/bundle \
    && rm -rf vendor/bundle/ruby/2.7.0/cache/*.gem \
    && find vendor/bundle/ruby/2.7.0/gems/ -name "*.c" -delete \
    && find vendor/bundle/ruby/2.7.0/gems/ -name "*.o" -delete

# Adding project files.
COPY . .

# Remove folders not needed in resulting image
RUN rm -rf tmp/cache spec

############### Build step done ###############

FROM ruby:2.7.2-alpine

# Set a variable for the install location.
ARG RAILS_ROOT=/usr/src/app
ARG PACKAGES="tzdata curl postgresql-client sqlite-libs yarn nodejs bash"

ENV RAILS_ENV=production
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"

WORKDIR $RAILS_ROOT

RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $PACKAGES


COPY --from=base $RAILS_ROOT $RAILS_ROOT

# Expose port 80.
EXPOSE 80

# Sets the footer of greenlight application with current build version
ARG version_code
ENV VERSION_CODE=$version_code
RUN cd bbb-live-streaming && npm install
# Start the application.
CMD ["bin/start"]
