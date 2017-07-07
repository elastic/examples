FROM docker.elastic.co/logstash/logstash:5.1.1
RUN /usr/share/logstash/bin/logstash-plugin install logstash-input-kafka
RUN rm -f /usr/share/logstash/pipeline/logstash.conf

ADD pipeline/logstash.conf /usr/share/logstash/pipeline/logstash.conf

ADD pipeline/cef_template.json /usr/share/logstash/cef_template.json