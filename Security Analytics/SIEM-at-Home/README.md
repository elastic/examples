# Elastic-SIEM-at-Home
References and examples for deploying an Elastic SIEM at Home running on Elastic Cloud

## beats-configs
Example configurations for beats when deploying an Elastic SIEM at Home running on Elasticsearch Service

Use the `General`, `Elastic Cloud`, and `Xpack Monitoring` sections within the `beats-general-config.yml` file for configurations used for all beats.

This example includes:
* Filebeat configuration for reference
* Packetbeat configuration for reference
* Winlogbeat configuration for reference

### Beats Privileges
For version 7.4, see documentation for each specific beat:
* [Auditbeat](https://www.elastic.co/guide/en/beats/auditbeat/7.4/feature-roles.html#privileges-to-setup-beats)
* [Filebeat](https://www.elastic.co/guide/en/beats/filebeat/7.4/feature-roles.html#privileges-to-setup-beats)
* [Packetbeat](https://www.elastic.co/guide/en/beats/packetbeat/7.4/feature-roles.html#privileges-to-setup-beats)
* [Winlogbeat](https://www.elastic.co/guide/en/beats/winlogbeat/7.4/feature-roles.html#privileges-to-setup-beats)
