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

$ curl -O https://artifacts.elastic.co/downloads/logstash/logstash-7.1.1.tar.gz

$ tar xzf logstash-7.1.1.tar.gz 

$ cd logstash-7.1.1

$ ./bin/logstash-plugin install logstash-input-jms

$ open http://www-01.ibm.com/support/docview.wss?uid=swg21683398&myns=swgws&mynp=OCSSFKSJ&mync=E

$ java -jar ~/Downloads/9.0.0.6-IBM-MQ-Install-Java-All.jar 

$ vi ~/Projects/logstash-7.1.1/config/ibmmq.yml
#
---
# IBM WebSphere MQ
wmq:
  :factory: com.ibm.mq.jms.MQQueueConnectionFactory
  :queue_manager: QM1
  :host_name: localhost
  :channel: DEV.APP.SVRCONN
  :port: 1414
  # Transport Type: com.ibm.mq.jms.JMSC::MQJMS_TP_CLIENT_MQ_TCPIP
  :transport_type: 1
  :username: app
  :password: password
  :require_jars:
    - /Users/droscigno/Projects/logstash-7.1.1/lib/IBMMQ/wmq/JavaSE/com.ibm.mq.allclient.jar


$ vi logstash.conf
input {
  jms {
    destination => "DEV.QUEUE.1"
    yaml_file => "/Users/droscigno/Projects/logstash-7.1.1/config/ibmmq.yml"
    yaml_section => "wmq"
  }
}
output {
  stdout { codec => rubydebug {}}
}

$ ../bin/logstash -f ./logstash.conf 

{
                  "message" => "Inserted into Dev.Queue.1 by hand",
          "JMS_IBM_PutTime" => "14342809",
             "jms_priority" => 0,
          "JMS_IBM_PutDate" => "20190531",
             "jms_reply_to" => nil,
           "JMS_IBM_Format" => "MQSTR   ",
               "JMSXUserID" => "mqm         ",
          "JMS_IBM_MsgType" => 8,
    "jms_delivery_mode_sym" => :non_persistent,
                 "jms_type" => nil,
           "jms_expiration" => 0,
               "@timestamp" => 2019-05-31T15:00:06.906Z,
         "JMS_IBM_Encoding" => 273,
          "jms_redelivered" => false,
           "jms_message_id" => "ID:414d5120514d31202020202020202020a93af15c02720822",
                "JMSXAppID" => "IBM MQ Web Admin/REST API   ",
        "JMSXDeliveryCount" => 1,
    "JMS_IBM_Character_Set" => "UTF-8",
                 "@version" => "1",
       "jms_correlation_id" => nil,
          "jms_destination" => nil,
            "jms_timestamp" => 1559313268090,
      "JMS_IBM_PutApplType" => 7
}
{
                  "message" => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sed magna a ante ultrices efficitur. Proin viverra arcu lobortis laoreet facilisis. Phasellus lobortis massa at ornare efficitur. Donec id magna nec orci feugiat placerat ut nec elit. Nam venenatis ipsum vulputate pellentesque pharetra.",
          "JMS_IBM_PutTime" => "15012458",
             "jms_priority" => 0,
          "JMS_IBM_PutDate" => "20190531",
             "jms_reply_to" => nil,
           "JMS_IBM_Format" => "MQSTR   ",
               "JMSXUserID" => "mqm         ",
          "JMS_IBM_MsgType" => 8,
    "jms_delivery_mode_sym" => :non_persistent,
                 "jms_type" => nil,
           "jms_expiration" => 0,
               "@timestamp" => 2019-05-31T15:01:27.558Z,
         "JMS_IBM_Encoding" => 273,
          "jms_redelivered" => false,
           "jms_message_id" => "ID:414d5120514d31202020202020202020a93af15c02760822",
                "JMSXAppID" => "IBM MQ Web Admin/REST API   ",
        "JMSXDeliveryCount" => 1,
    "JMS_IBM_Character_Set" => "UTF-8",
                 "@version" => "1",
       "jms_correlation_id" => nil,
          "jms_destination" => nil,
            "jms_timestamp" => 1559314884580,
      "JMS_IBM_PutApplType" => 7
}
```
