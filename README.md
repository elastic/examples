Kibana Armed Bandit
===================

Logging is key in every setup: having useful logs from the components in your
environment is your best tool in diagnosing issues and keeping track of
the health of your applications.

Docker-based deployments are no exception of this rule. In this training we will evaluate kibana features, upon reaching an E*K stack.

This project is the workshop part of the [Kibana training](https://git.renault-digital.com/common/training/tree/master/kibana)

Dependencies
------------

- docker, docker-compose
- make
- ngrok (optional)

Installation
------------

Docker, the new trending containerization technique, is winning hearts with its lightweight, portable, "build once, configure once and run anywhere" functionalities.

To run this project on your computer you only need docker, you probably already
know this technology but in case you don't we have written a training [here](https://git.renault-digital.com/common/training/blob/master/docker/docker-intro-part1.md) and you can find the documentation about how to install the docker engine [here](https://docs.docker.com/engine/installation/) in the docker official website.

Everything Ok...? Let's start!

Usage
-----

Makefiles are a simple way to organize commands, to see this project usefull
system commands run `make help`

1 - Start the testing stack

This docker-based stack is compose with these components:

- simple ruby application
- elasticsearch container(s)
- logs shipper
- kibana

> Hum... I have to just run `make start` ?
>> Yeah!

2 - Open your kibana

3 - Stress your application

4 - Create cool dashboards!

Contributing
------------

This project is a part of a collection of resources for people who want to learn how to run and contribute to improve projects quality at renault-digital.

If you find bugs or want to improve the documention, please feel free to
contribute!

Happy coding!


