# Reference files for deploying Beats in production

These YAML files for Filebeat, Metricbeat, and Heartbeat go along with the webinar / video *Five Best Practices for ingesting data with Beats*.  Not every detail is included in the webinar or the files, for example the settings for configuring the Elasticsearch template for each Beat are left to the reader as they are dependent on the size of your cluster.  There are URLs in the YAML files to point you to information on sizing if you need it.

If you are looking at these files without watching the webinar please note that you will need to create and populate the keystores for each Beat.

# Links from the webinar slides

[RBAC for Filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/feature-roles.html)

[Configuring load balancing to ingest nodes](https://www.elastic.co/guide/en/beats/filebeat/current/elasticsearch-output.html#hosts-option)

[Elastic Common Schema](https://www.elastic.co/blog/introducing-the-elastic-common-schema)

[Beats Add Field processor](https://www.elastic.co/guide/en/beats/filebeat/current/add-fields.html)

[Beats spooling to disk](https://www.elastic.co/guide/en/beats/filebeat/current/configuring-internal-queue.html#configuration-internal-queue-spool)

[Monitoring Filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/monitoring.html)

[Index lifecycle management](https://www.elastic.co/guide/en/kibana/current/managing-index-lifecycle-policies.html)

[Beat log level](https://www.elastic.co/guide/en/beats/filebeat/current/configuration-logging.html)

[Heartbeat observer metadata](https://www.elastic.co/guide/en/beats/heartbeat/current/add-observer-metadata.html)

[Filebeat SSL](https://www.elastic.co/guide/en/beats/filebeat/current/configuration-ssl.html)

[Filebeat FAQs](https://www.elastic.co/guide/en/beats/filebeat/current/faq.html)
