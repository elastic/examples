# Pull base image.
FROM dockerfile/java:oracle-java8
ENV ES_PKG_NAME elasticsearch-1.4.2
ENV KIBANA_PKG_NAME kibana-4.0.0-beta3
# Install Elasticsearch and Kibana.
RUN \
cd / && \
wget https://download.elasticsearch.org/elasticsearch/elasticsearch/$ES_PKG_NAME.tar.gz && \
tar xvzf $ES_PKG_NAME.tar.gz && \
rm -f $ES_PKG_NAME.tar.gz && \
mv /$ES_PKG_NAME /elasticsearch && \
wget https://download.elasticsearch.org/kibana/kibana/$KIBANA_PKG_NAME.tar.gz && \
tar xvzf $KIBANA_PKG_NAME.tar.gz && \
rm -f $KIBANA_PKG_NAME.tar.gz && \
mv /$KIBANA_PKG_NAME /kibana

# Define mountable directories.
VOLUME ["/data"]

ADD config/elasticsearch.yml /elasticsearch/config/elasticsearch.yml
ADD config/kibana.yml /kibana/config/kibana.yml
ADD config/lapdsnap /lapdsnap
ADD config/commands.sh /commands.sh

# Define working directory.
WORKDIR /data

# Expose ports.
# - 9200: HTTP
# - 9300: transport
# - 5601: kibana
EXPOSE 9200
EXPOSE 9300
EXPOSE 5601

# Define default command.
CMD sh /commands.sh
