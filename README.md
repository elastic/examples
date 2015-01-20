elasticsearch/demo
====

This is a collection of demos to help you get familiar with Elasticsearch, Logstash and Kibana. Most will require some minimal technical skills to get running. While we are aiming to make these as easy as possible to set up, we're also trying to leverage tools like [Vagrant](https://www.vagrantup.com/) and [Puppet](http://puppetlabs.com/), not just to simplify the distribution and setup of these demos, but also as a way to introduce people to modern development tools. Feel free to file issues for bugs or enhancement requests and even contribute code via pull requests. 

You can find specific details for each demo in their respective README. The following information pertains to the demo repo as a whole.

# Contents

- [Quick start](#quick-start)
- [Contributing](#contributing)

# Quick start

You can find the latest release of the demo repo as .zip and .tar.gz files in the "releases" area of this Github repo:

[https://github.com/elasticsearch/demo/releases](https://github.com/elasticsearch/demo/releases)

Download a .zip or .tar.gz release, unarchive it, then following instructions in the README file of the demo you're interested in.

# Contributing

If you have a bugfix or new demo that you would like to contribute to the Elasticsearch demo repo, please open an issue about it before you start working on it. Talk about what you would like to do. It may be that somebody is already working on it or we can help provide guidance to make it successful.

## Development model

The demo repo consists of multiple demos, which can make things tricky in terms of making stable releases if various demos are in different states of stability. In order to avoid situations where we cannot perform a release for a new demo due to an existing demo being in a non-working state, we will try to enforce using the fork and pull model. Here's a helpful article on fork and pull on Github: [https://help.github.com/articles/fork-a-repo/](https://help.github.com/articles/fork-a-repo/).

## Suggested deliverables / packaging

Since one of the major goals of this repo is to help people learn about Elasticsearch, Logstash and Kibana, we're asking contributors to consider delivering more than simply a set of code and configuration files as a part of thier demo. Some strongly suggested assets that should be delivered with each demo are (in order of requiredness):

* README with well-written instructions, pre-requisites, etc.
* single script to install / deploy demo
* Logstash config files used to process data set
* Elasticsearch mappings used for data set
* Kibana dashboard files
* raw data files hosted on Amazon S3 or other file repository
* Elasticsearch index snapshot hosted on S3 or other file repo
* ensured compatibility with Windows, Mac OS X and Linux
* blog post to describe demo in narrative form. In other words, not a technical guide but more of a description of the problems solved by using ELK on this data set along with one or two step-by-step clickpaths demonstrating that via words and screen shots.
* video blog of you demoing your demo

### Packaging

Demos can come in many different forms so it might not be worth being overly prescriptive in how a particular demo should be packaged. However, in accordance with the purpose of this demo repo, each demo should be relatively easy to install/deploy for a person with some technical abilities, with as few steps or actions as possible. 

This can mean providing a bash script that encapsulates the entire setup of the demo data set. Or it could involve relying on a combination of Puppet and Vagrant to bring up the demo with a single Vagrant command.


## Release process

While this demo repo doesn't represent packaged software, it'd be helpful to maintain sanity by incorporating a lightweight release process to this project. 

There are major and minor releases. 

A major release will typically be done whenever there is a new demo ready to be distributed for general consumption. A major release can consist of 1) one or more new demos ready for public consumption and/or 2) a rollup of bug fixes and enhancements to existing demos since the last release. 

A minor release will be done when one or more bug fixes must be made to an existing demo.

In order to keep things simple, there will be no concept of branching in this repo. For example, if Demo A was released in v1.0 and Demo B was released in v2.0, a new bug fix to Demo A will result in a minor release v2.1, not a minor release v1.1 on a v1.0 branch. 

All releases (major and minor) of the demo repo should be made available in .zip and .tar.gz formats.



