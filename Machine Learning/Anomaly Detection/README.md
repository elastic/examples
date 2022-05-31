# Anomaly Detection

This directory contains example anomaly detection job configurations.

TIP: Kibana can also recognize certain types of data and provide specialized
wizards for that context. For more details, refer to
[supplied anomaly detection configurations](https://www.elastic.co/guide/en/machine-learning/8.0/ootb-ml-jobs.html).

#### Unsupervised ML Archive - Past Versions of the Anomaly Detection Jobs

These are prior versions of the version 3 ML jobs shipping in Elastic 8.3. They are only needed if running older data sources like Beats or Endpoints in the 7.x version range.

* security_linux: version 2 of the Linux anomaly detection jobs, from 2020.
* security_windows: version 2 of the Windows anomaly detection jobs, from 2020.

* siem_auditbeat: version 1 of the Linux anomaly detection jobs, from 2019.
* siem_winlogbeat: version 1 of the Windows anomaly detection jobs, from 2019.
* siem_winlogbeat_auth: an anomaly detection job for Windows RDP login events, from 2019.
* siem_auditbeat_auth: an anomaly detection job for auth events developed on Linux. The first ML job shipped in the Security solution in 2019.