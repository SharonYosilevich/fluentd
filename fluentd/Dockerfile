FROM fluent/fluentd:v1.16.5-debian-1.0
USER root

RUN gem install elasticsearch -v 7.17.10 && \
  gem install fluent-plugin-elasticsearch --no-document --version 5.4.3

# Switch to the desired user
USER fluent