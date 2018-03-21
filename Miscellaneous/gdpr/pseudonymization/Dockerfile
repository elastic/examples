ARG TAG
FROM docker.elastic.co/logstash/logstash-oss:$TAG
MAINTAINER Dale McDiarmid "dalem@elastic.co"

RUN rm /usr/share/logstash/pipeline/logstash.conf
RUN /usr/share/logstash/bin/logstash-plugin update logstash-filter-ruby
