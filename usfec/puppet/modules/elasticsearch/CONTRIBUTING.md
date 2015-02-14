If you have a bugfix or new feature that you would like to contribute to this puppet module, please find or open an issue about it first. Talk about what you would like to do. It may be that somebody is already working on it, or that there are particular issues that you should know about before implementing the change.

We enjoy working with contributors to get their code accepted. There are many approaches to fixing a problem and it is important to find the best approach before writing too much code.

The process for contributing to any of the Elasticsearch repositories is similar.

1. Sign the contributor license agreement
Please make sure you have signed the [Contributor License Agreement](http://www.elasticsearch.org/contributor-agreement/). We are not asking you to assign copyright to us, but to give us the right to distribute your code without restriction. We ask this of all contributors in order to assure our users of the origin and continuing existence of the code. You only need to sign the CLA once.

2. Run the rspec tests and ensure it completes without errors with your changes.

3. Run the acceptance tests

These instructions are for Ubuntu 14.04

* install docker 0.11.1 
 * wget https://get.docker.io/ubuntu/pool/main/l/lxc-docker/lxc-docker_0.11.1_amd64.deb
 * wget https://get.docker.io/ubuntu/pool/main/l/lxc-docker-0.11.1/lxc-docker-0.11.1_0.11.1_amd64.deb
 * sudo dpkg -i lxc-docker_0.11.1_amd64.deb lxc-docker-0.11.1_0.11.1_amd64.deb
 * sudo usermod -a -G docker $USER
* export BUNDLE_GEMFILE=.gemfiles/Gemfile.beaker
* export RS_SET='ubuntu-server-1404-x64' # see spec/acceptance/nodesets for more
* export VM_PUPPET_VERSION='3.6.0'  
* wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.0.deb
* wget https://forgeapi.puppetlabs.com/v3/files/puppetlabs-stdlib-3.2.0.tar.gz
* wget https://forgeapi.puppetlabs.com/v3/files/puppetlabs-apt-1.4.2.tar.gz
* export files_dir=$(pwd)
* bundle install
* bundle exec rspec --format RspecJunitFormatter --out rspec.xml spec/acceptance/*_spec.rb

```
    Hypervisor for ubuntu-14-04 is docker
    Beaker::Hypervisor, found some docker boxes to create
    Provisioning docker
    provisioning ubuntu-14-04
    ...
    Finished in 18 minutes 6 seconds
    224 examples, 0 failures, 3 pending
```

4. Rebase your changes
Update your local repository with the most recent code from the main this puppet module repository, and rebase your branch on top of the latest master branch. We prefer your changes to be squashed into a single commit.

5. Submit a pull request
Push your local changes to your forked copy of the repository and submit a pull request. In the pull request, describe what your changes do and mention the number of the issue where discussion has taken place, eg “Closes #123″.

Then sit back and wait. There will probably be discussion about the pull request and, if any changes are needed, we would love to work with you to get your pull request merged into this puppet module.
