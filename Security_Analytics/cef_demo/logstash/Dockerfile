FROM docker.elastic.co/logstash/logstash:5.1.1
RUN rm -f /usr/share/logstash/pipeline/logstash.conf
ADD pipeline/logstash.conf /usr/share/logstash/pipeline/logstash.conf
ADD pipeline/ElasticSearch_CEF_Template /usr/share/logstash/ElasticSearch_CEF_Template