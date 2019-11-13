# Elastic-SIEM-at-Home
Monitoring your servers and workstations doesn't have to be difficult or expensive. Learn how to use Elastic SIEM at home or for your small business. This `SIEM-at-Home` folder in the `elastic/examples` repo contains references and examples for the **Elastic SIEM for home and small business** blog series:
1. [Elastic SIEM for home and small business: Getting started](https://www.elastic.co/blog/elastic-siem-for-small-business-and-home-1-getting-started)
2. [Elastic SIEM for home and small business: Securing cluster access](https://www.elastic.co/blog/elastic-siem-for-small-business-and-home-2-securing-cluster-access)
3. Elastic SIEM for home and small business: GeoIP data and Beats config review _(coming soon)_

## beats-configs
Example configurations for beats when deploying an Elastic SIEM at Home running on Elasticsearch Service

The example sections within the `beats-general-config.yml` file are configurations used for all beats.

### Beats Privileges
For version 7.4, see documentation for each specific beat:
* [Auditbeat](https://www.elastic.co/guide/en/beats/auditbeat/7.4/feature-roles.html#privileges-to-setup-beats)
* [Filebeat](https://www.elastic.co/guide/en/beats/filebeat/7.4/feature-roles.html#privileges-to-setup-beats)
* [Packetbeat](https://www.elastic.co/guide/en/beats/packetbeat/7.4/feature-roles.html#privileges-to-setup-beats)
* [Winlogbeat](https://www.elastic.co/guide/en/beats/winlogbeat/7.4/feature-roles.html#privileges-to-setup-beats)
