# Contributing an Example

All Contributions should be contained with a folder that describes the content of the example e.g. "ElasticStack_Twitter".  The structure of the example, within the folder itself, can be flexible but should always include:

* A README.md describing:
    - The supported component versions e.g Logstash 5.0. 
    - Any installation instructions that are unique to those detailed in the [Installation & Setup Guide](https://github.com/elastic/examples/blob/master/Installation%20and%20Setup.md)
    - Steps for loading any required data into Elasticsearch
    - Any other steps required to ensure the demo is functional
    - Scripts should be documented and dependencies available in a standard format e.g. Python a requirements.txt and pip would be appropriate. Detail tested language versions for scripts e.g.Python 3.5.x
    - Instructions for obtaining datasets
   
* .gitignore file describing file exclusions e.g. generated files.
* Any configuration files for the demo to be functional.  This can include an export of kibana dashboards.
* Any supporting scripts and code


Other Considerations:

* For files greater than 10mb (e.g. sample datasets) include appropriate download instructions from an external url. Small data files are acceptable.
* Consider the license for any datasets.  Please specify the license on any pull request if known.  If license cannot be determined please state.
