FROM python:2-jessie

RUN set -eu \
  && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server sudo \
  && curl -o /usr/local/bin/jq -L https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && chmod +x /usr/local/bin/jq \
  && pip install yq ansible awscli

ENV YARN_VERSION 1.13.0

COPY --from=node:10.15.3-jessie /usr/local/bin/node /usr/local/bin/node
COPY --from=node:10.15.3-jessie /usr/local/lib/node_modules /usr/local/bin/node_modules
COPY --from=node:10.15.3-jessie /opt/yarn-v$YARN_VERSION /opt/yarn-v$YARN_VERSION

RUN set -eu \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg

RUN set -eu \
  && node -v && yarn -v

RUN mkdir -p /usr/local/etc \
  && { \
  echo 'install: --no-document'; \
  echo 'update: --no-document'; \
  } >> /usr/local/etc/gemrc

ENV RUBYGEMS_VERSION 3.0.3

COPY --from=ruby:2.4.6-jessie /usr/local/bin/ruby /usr/local/bin/ruby
COPY --from=ruby:2.4.6-jessie /usr/local/bin/gem /usr/local/bin/gem
COPY --from=ruby:2.4.6-jessie /usr/local/bin/bundle /usr/local/bin/bundle
COPY --from=ruby:2.4.6-jessie /usr/local/bin/erb /usr/local/bin/erb
COPY --from=ruby:2.4.6-jessie /usr/local/bin/irb /usr/local/bin/irb
COPY --from=ruby:2.4.6-jessie /usr/local/bin/rake /usr/local/bin/rake
COPY --from=ruby:2.4.6-jessie /usr/local/bin/rdoc /usr/local/bin/rdoc
COPY --from=ruby:2.4.6-jessie /usr/local/bin/ri /usr/local/bin/ri
COPY --from=ruby:2.4.6-jessie /usr/local/bin/update_rubygems /usr/local/bin/update_rubygems
COPY --from=ruby:2.4.6-jessie /usr/local/lib/libruby.so /usr/local/lib/libruby.so
COPY --from=ruby:2.4.6-jessie /usr/local/lib/libruby.so.2.4 /usr/local/lib/libruby.so.2.4
COPY --from=ruby:2.4.6-jessie /usr/local/lib/libruby.so.2.4.6 /usr/local/lib/libruby.so.2.4.6
COPY --from=ruby:2.4.6-jessie /usr/local/lib/ruby /usr/local/lib/ruby

RUN set -ex \
  \
  && gem update --system "$RUBYGEMS_VERSION" && rm -r /root/.gem/ \
  && ruby --version && gem --version && bundle --version

ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
  BUNDLE_SILENCE_ROOT_WARNING=1 \
  BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $GEM_HOME/bin:$BUNDLE_PATH/gems/bin:$PATH
RUN mkdir -p "$GEM_HOME" && chmod 777 "$GEM_HOME"