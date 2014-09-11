#Elasticsearch Puppet module

[![Build Status](https://travis-ci.org/elasticsearch/puppet-elasticsearch.png?branch=master)](https://travis-ci.org/elasticsearch/puppet-elasticsearch)

####Table of Contents

1. [Overview](#overview)
2. [Module description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with Elasticsearch](#setup)
  * [The module manages the following](#the-module-manages-the-following)
  * [Requirements](#requirements)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Advanced features - Extra information on advanced usage](#advanced-features)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
8. [Support - When you need help with this module](#support)



##Overview

This module manages Elasticsearch (http://www.elasticsearch.org/overview/elasticsearch/)

##Module description

The elasticsearch module sets up Elasticsearch instances and can manage plugins and templates.

This module has been tested against ES 1.0 and up.

##Setup

###The module manages the following

* Elasticsearch repository files.
* Elasticsearch package.
* Elasticsearch configuration file.
* Elasticsearch service.
* Elasticsearch plugins.
* Elasticsearch templates.

###Requirements

* The [stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) Puppet library.

#### Repository management
When using the repository management you will need the following dependency modules:

* Debian/Ubuntu: [Puppetlabs/apt](http://forge.puppetlabs.com/puppetlabs/apt)
* OpenSuSE: [Darin/zypprepo](https://forge.puppetlabs.com/darin/zypprepo)

##Usage

###Main class

####Install a specific version

```puppet
class { 'elasticsearch':
  version => '1.2.1'
}
```

Note: This will only work when using the repository.

####Automatic upgrade of the software ( default set to false )
```
class { 'elasticsearch':
  autoupgrade => true
}
```

####Removal/decommissioning
```puppet
class { 'elasticsearch':
  ensure => 'absent'
}
```

####Install everything but disable service(s) afterwards
```puppet
class { 'elasticsearch':
  status => 'disabled'
}
```

###Instances

This module works with the concept of instances.

####Quick setup
```puppet
elasticsearch::instance { 'es-01': }
```

This will set up its own data directory and set the node name to `$hostname-$instance_name`

####Advanced options

Instance specific options can be given:

```puppet
elasticsearch::instance { 'es-01':
  config => { },        # Configuration hash
  init_defaults => { }, # Init defaults hash
  datadir => [ ],       # Data directory
}
```

See [Advanced features](#advanced-features) for more information

###Plug-ins

Install [a variety of plugins](http://www.elasticsearch.org/guide/plugins/):

####From official repository
```puppet
elasticsearch::plugin{'lmenezes/elasticsearch-kopf':
  module_dir => 'kopf'
}
```
####From custom url
```puppet
elasticsearch::plugin{ 'elasticsearch-jetty':
  module_dir => 'jetty',
  url        => 'https://oss-es-plugins.s3.amazonaws.com/elasticsearch-jetty/elasticsearch-jetty-1.2.1.zip'
}
```
###Templates

#### Add a new template

This will install and/or replace the template in Elasticsearch:

```puppet
elasticsearch::template { 'templatename':
  file => 'puppet:///path/to/template.json'
}
```

#### Delete a template

```puppet
elasticsearch::template { 'templatename':
  ensure => 'absent'
}
```

#### Host

By default it uses localhost:9200 as host. you can change this with the `host` and `port` variables

```puppet
elasticsearch::template { 'templatename':
  host => $::ipaddress,
  port => 9200
}
```

###Bindings / Clients

Install a variety of [clients/bindings](http://www.elasticsearch.org/guide/clients/):

####Python

```puppet
elasticsearch::python { 'rawes': }
```

####Ruby
```puppet
elasticsearch::ruby { 'elasticsearch': }
```

###Package installation

There are 2 different ways of installing the software

####Repository

This option allows you to use an existing repository for package installation.
The `repo_version` corresponds with the major version of Elasticsearch.

```puppet
class { 'elasticsearch':
  manage_repo  => true,
  repo_version => '1.2',
}
```

####Remote package source

When a repository is not available or preferred you can install the packages from a remote source:

#####http/https/ftp
```puppet
class { 'elasticsearch':
  package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.2.1.deb'
}
```

#####puppet://
```puppet
class { 'elasticsearch':
  package_url => 'puppet:///path/to/elasticsearch-1.2.1.deb'
}
```

#####Local file
```puppet
class { 'elasticsearch':
  package_url => 'file:/path/to/elasticsearch-1.2.1.deb'
}
```

###Java installation

Most sites will manage Java separately; however, this module can attempt to install Java as well.

```puppet
class { 'elasticsearch':
  java_install => true
}
```

Specify a particular Java package/version to be installed:

```puppet
class { 'elasticsearch':
  java_install => true,
  java_package => 'packagename'
}
```

###Service management

Currently only the basic SysV-style [init](https://en.wikipedia.org/wiki/Init) and [Systemd](http://en.wikipedia.org/wiki/Systemd) service providers are supported, but other systems could be implemented as necessary (pull requests welcome).


####Defaults File

The *defaults* file (`/etc/defaults/elasticsearch` or `/etc/sysconfig/elasticsearch`) for the Elasticsearch service can be populated as necessary. This can either be a static file resource or a simple key value-style  [hash](http://docs.puppetlabs.com/puppet/latest/reference/lang_datatypes.html#hashes) object, the latter being particularly well-suited to pulling out of a data source such as Hiera.

#####file source
```puppet
class { 'elasticsearch':
  init_defaults_file => 'puppet:///path/to/defaults'
}
```
#####hash representation
```puppet
$config_hash = {
  'ES_USER' => 'elasticsearch',
  'ES_GROUP' => 'elasticsearch',
}

class { 'elasticsearch':
  init_defaults => $config_hash
}
```

Note: `init_defaults` hash can be passed to the main class and to the instance.

##Advanced features


###Data directories

There are 4 different ways of setting data directories for Elasticsearch.
In every case the required configuration options are placed in the `elasticsearch.yml` file.

####Default
By default we use:

`/usr/share/elasticsearch/data/$instance_name`

Which provides a data directory per instance. 


####Single global data directory

```puppet
class { 'elasticsearch':
  datadir => '/var/lib/elasticsearch-data'
}
```
Creates the following for each instance:

`/var/lib/elasticsearch-data/$instance_name`

####Multiple Global data directories

```puppet
class { 'elasticsearch:
  datadir => [ '/var/lib/es-data1', '/var/lib/es-data2']
}
```
Creates the following for each instance:
`/var/lib/es-data1/$instance_name`
and
`/var/lib/es-data2/$instance_name`


####Single instance data directory

```puppet
class { 'elasticsearch': }

elasticsearch::instance { 'es-01':
  datadir => '/var/lib/es-data-es01'
}
```
Creates the following for this instance:
`/var/lib/es-data-es01`

####Multiple instance data directories

```puppet
class { 'elasticsearch': }

elasticsearch::instance { 'es-01':
  datadir => ['/var/lib/es-data1-es01', '/var/lib/es-data2-es01']
}
```
Creates the following for this instance:
`/var/lib/es-data1-es01`
and
`/var/lib/es-data2-es01`


###Main and instance configurations

The `config` option in both the main class and the instances can be configured to work together.

The options in the `instance` config hash will merged with the ones from the main class and override any duplicates.

#### Simple merging

```puppet
class { 'elasticsearch':
  config => { 'cluster.name' => 'clustername' }
}

elasticsearch::instance { 'es-01':
  config => { 'node.name' => 'nodename' }
}
elasticsearch::instance { 'es-02':
  config => { 'node.name' => 'nodename2' }
}

```

This example merges the `cluster.name` together with the `node.name` option.

#### Overriding 

When duplicate options are provided, the option in the instance config overrides the ones from the main class.

```puppet
class { 'elasticsearch':
  config => { 'cluster.name' => 'clustername' }
}

elasticsearch::instance { 'es-01':
  config => { 'node.name' => 'nodename', 'cluster.name' => 'otherclustername' }
}

elasticsearch::instance { 'es-02':
  config => { 'node.name' => 'nodename2' }
}
```

This will set the cluster name to `otherclustername` for the instance `es-01` but will keep it to `clustername` for instance `es-02`

####Configuration writeup

The `config` hash can be written in 2 different ways:

##### Full hash writeup

Instead of writing the full hash representation:
```puppet
class { 'elasticsearch':
  config                 => {
   'cluster'             => {
     'name'              => 'ClusterName',
     'routing'           => {
        'allocation'     => {
          'awareness'    => {
            'attributes' => 'rack'
          }
        }
      }
    }
  }
}
```
##### Short hash writeu
```puppet
class { 'elasticsearch':
  config => {
    'cluster' => {
      'name' => 'ClusterName',
      'routing.allocation.awareness.attributes' => 'rack'
    }
  }
}
```


##Limitations

This module has been built on and tested against Puppet 2.7 and higher.

The module has been tested on:

* Debian 6/7
* CentOS 6
* Ubuntu 12.04, 13.x, 14.x
* OpenSuSE 12.x

Testing on other platforms has been light and cannot be guaranteed.

##Development


##Support

Need help? Join us in [#elasticsearch](https://webchat.freenode.net?channels=%23elasticsearch) on Freenode IRC or subscribe to the [elasticsearch@googlegroups.com](https://groups.google.com/forum/#!forum/elasticsearch) mailing list.
