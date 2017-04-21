FROM kartoza/geoserver
MAINTAINER Elastic Infra <infra@elastic.co>

ENV GEOSERVER_DATA_DIR /opt/geoserver/data_dir

RUN mkdir -p $GEOSERVER_DATA_DIR/shapefiles

COPY *.shp $GEOSERVER_DATA_DIR/shapefiles/
