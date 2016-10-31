# Introduction

This is a collection of examples to help you get familiar with the Elastic stack. Each example folder includes a README with detailed instructions for getting up and running with the  particular example. The following information pertains to the [examples](https://github.com/elastic/examples) repo as a whole.

### Contents

- [Quick start](#quick-start)
- [Contributing](#contributing)

### Quick start

You have a few options to get started with the examples:

- If you want to try them all, you can [download the entire repo ](https://github.com/elastic/examples/archive/master.zip). Or, if you are familiar with Git, you can [clone the repo](https://github.com/elastic/examples.git). Then, simply follow the instructions in the individual README of the examples you're interested in to get started.

- If you are only interested in a specific example or two, you can download the contents of just those examples (instructions in the individual READMEs).

### Contributing

If you would like to contribute new examples to the Elastic examples repo, we would love to hear from you!!! Please open an issue briefly describing your content before you start working on it. We would love to provide guidance to make for a pleasant contribution experience.

#### Packaging
One of the major goals of this repo is to help people learn about the Elastic Stack. Which is why we are asking contributors to consider delivering more than simply a set of code and configuration files as a part of their demo. In accordance with the purpose of this repo, each example should be relatively easy to install and deploy for a person with some technical abilities. We do not want to be being overly prescriptive in how a particular demo is packaged, but below is the list of assets that we recommend be delivered with each demo.

* **README**
  * clear instructions to install and run the example
  * version of Elastic Stack (and other tools) that the example was tested with
  * additional tool requirements (along with instructions to use / download)
  * known gotchas, system requirements, compatibility issue, etc.
* **Code**
  * Logstash config files to process and ingest data
  * Template with index mappings (if needed)
  * Kibana config file to load a prebuilt Kibana dashboard  
  * Any other code that is a part of the instruction set
* **Data** <br>
  You can either provide the data file with the example (for small sample datasets), or provide instructions / link to download the raw data (or Elasticsearch index snapshot) from another source (such as Amazon S3)
* **Story** <br>
    If your example revolves around an analysis of a real-world dataset, try to include some color commentary to describe analysis in narrative form. How is data being used to solve a problem? What interesting insights were mined from this data? You can include this information in the README, or provide links to external blog / video, or perhaps document the narrative with markdown widgets in the Kibana dashboard.

#### Feedback & Suggestion

Please open an issue if you find a bug, run into issues or would like to provide feedback / suggestions. We will try our best to respond in a timely manner!
