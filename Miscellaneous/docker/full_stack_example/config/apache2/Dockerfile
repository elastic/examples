FROM httpd:2.4.20
LABEL "co.elastic.logs/module"="apache2"
LABEL "co.elastic.logs/fileset.stdout"="access"
LABEL "co.elastic.logs/fileset.stderr"="error"
RUN apt-get update && apt-get install -y curl
HEALTHCHECK CMD curl -f http://localhost
COPY ./httpd.conf /usr/local/apache2/conf/httpd.conf
