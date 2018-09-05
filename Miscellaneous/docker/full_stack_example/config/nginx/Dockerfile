FROM nginx:1.9
RUN apt-get update && apt-get install -y curl
HEALTHCHECK CMD curl -f http://localhost/server-status
LABEL "co.elastic.logs/module"="nginx"
LABEL "co.elastic.logs/fileset.stdout"="access"
LABEL "co.elastic.logs/fileset.stderr"="error"
COPY ./nginx.conf /etc/nginx/
