FROM docker.elastic.co/logstash/logstash:5.6.0
RUN rm -f /usr/share/logstash/pipeline/logstash.conf
RUN rm -f /usr/share/logstash/config/logstash.yml
ADD config/logstash.yml /usr/share/logstash/config/logstash.yml
CMD /usr/share/logstash/bin/logstash --modules arcsight --setup