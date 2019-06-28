# Collecting records from IBM MQ with Logstash
This example is based on Logstash 7.2 and [JMS input plugin 3.1.0](https://www.elastic.co/guide/en/logstash-versioned-plugins/current/v3.1.0-plugins-inputs-jms.html)

# History file
```
:Projects$ git clone https://github.com/saudurehman/logstash_jms_ibm_mq.git

$ open --background -a Docker

$ docker pull ibmcom/mq:latest

$ docker images | grep mq

$ docker volume create qm1data

$ docker network create mq-demo-network

$ docker run \
  --env LICENSE=accept \
  --env MQ_QMGR_NAME=QM1 \
  --volume qm1data:/mnt/mqm \
  --publish 1414:1414 \
  --publish 9443:9443 \
  --network mq-demo-network \
  --network-alias qmgr \
  --detach \
  --env MQ_APP_PASSWORD=password \
  ibmcom/mq:latest

$ docker ps # get container name

$ docker exec -it <container name> /bin/bash

(mq:9.1.2.0)mqm@884565f04872:/$ dspmqver

(mq:9.1.2.0)mqm@884565f04872:/$ dspmq

QMNAME(QM1)                                               STATUS(Running)
(mq:9.1.2.0)mqm@884565f04872:/$ exit

exit

$ open https://localhost:9443/ibmmq/console

$ curl -O https://artifacts.elastic.co/downloads/logstash/logstash-7.2.0.tar.gz

$ tar xzf logstash-7.2.0.tar.gz 

$ cd logstash-7.2.0

$ # Copy logstah.conf from the elastic/examples/Miscellaneous/ibm-mq-logstash

$ ./bin/logstash-plugin install logstash-input-jms

$ open http://www-01.ibm.com/support/docview.wss?uid=swg21683398&myns=swgws&mynp=OCSSFKSJ&mync=E

$ java -jar ~/Downloads/9.0.0.6-IBM-MQ-Install-Java-All.jar 

$ ./bin/logstash -f config/logstash.conf 
```
