LAPD Crime Reports Demo
=====

A script for this demo can be found in the 'Groot' section of the wiki: https://elasticsearch.atlassian.net/wiki/display/PRES/LAPD+Demo

The original raw data used in this demo can be found [here](https://data.lacity.org/A-Safe-City/LAPD-Crime-and-Collision-Raw-Data-for-2013/iatr-8mqm).

#Installation

In order to run this demo, you'll need Docker. Instructions for installing Docker on various operating systems can be found here: https://docs.docker.com/installation/

Follow these steps to run this demo locally on your machine:

1. Install Docker (if you don't have it on your machine yet).
2. Start Docker.
3. Download the demo from the Docker Hub: `docker pull krijnmossel/lapd_elasticsearch_demo`
4. Run the demo: `docker run -d -p 55555:5601 krijnmossel/lapd_elasticsearch_demo`
5. Direct your browser to `http://<host>:55555`. If you're on Mac or Windows, the value of `<host>` is the ip address of the boot2docker VM, which you can retrieve by running `boot2docker ip` on the command line. On other operating systems, `<host>` is equal to "localhost".

###Roll your own

Instead of downloading the demo from the Docker Hub, you can build the Docker image on your own machine:

1. Copy the files from this Github folder to a separate directory on your local filesystem.
2. Run `docker build .`.
3. You can then run the demo with `docker run -d -p 55555:5601 <image-id>`, where `<image-id>` is the id that resulted from the build in the previous step.
