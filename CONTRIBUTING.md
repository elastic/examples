# Contributing an Example

If you would like to contribute new examples to the Elastic examples repo, we would love to hear from you!!! Please open an issue briefly describing your content before you start working on it. We would love to provide guidance to make for a pleasant contribution experience.

## Packaging
One of the major goals of this repo is to help people learn about the Elastic Stack. Which is why we are asking contributors to consider delivering more than simply a set of code and configuration files as a part of their demo. In accordance with the purpose of this repo, each example should be relatively easy to install and deploy for a person with some technical abilities. We do not want to be being overly prescriptive in how a particular demo is packaged, but below is the list of assets that we recommend be delivered with each demo.

All Contributions should be contained with a folder that describes the content of the example e.g. "ElasticStack_Twitter".  The structure of the example, within the folder itself, can be flexible but should always include:

  * Clear instructions to install and run the example.  Especially consider any installation instructions that are unique to those detailed in the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md)
  * Steps for loading any required data into Elasticsearch
  * Version of Elastic Stack (and other tools) that the example was tested with
  * Additional tool requirements (along with instructions to use / download)
  * Known gotchas, system requirements, compatibility issue, etc.
  * Logstash config files to process and ingest data
  * Template with index mappings (if needed)
  * Kibana config file to load a prebuilt Kibana dashboard  
  * Any other code that is a part of the instruction set. Scripts should be documented and dependencies available in a standard format e.g.for Python a requirements.txt and pip would be appropriate. Always detail tested language versions for scripts e.g.Python 3.5.x

* **Data** <br>
  You can either provide the data file with the example (for small sample datasets), or provide instructions / link to download the raw data (or Elasticsearch index snapshot) from another source (such as Amazon S3). 10mb is a reasonable threshold before moving to an external download- but this shouldn't be considered a hardline.
  
* **Story** <br>
    If your example revolves around an analysis of a real-world dataset, try to include some color commentary to describe analysis in narrative form. How is data being used to solve a problem? What interesting insights were mined from this data? You can include this information in the README, or provide links to external blog / video, or perhaps document the narrative with markdown widgets in the Kibana dashboard.

## Other Considerations:

* Consider the license for any datasets.  Please specify the license on any pull request if known.  If license cannot be determined please state.
* Consider adding a .gitignore file describing file exclusions e.g. generated files.

## Feedback & Suggestion

Please open an issue if you find a bug, run into issues or would like to provide feedback / suggestions. We will try our best to respond in a timely manner!



