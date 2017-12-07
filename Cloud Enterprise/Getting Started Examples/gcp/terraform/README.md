# A sample installation of Elastic Cloud Enterprise on GCP

## Details

This tree provides a basic test bed for an installation of [Elastic Cloud Enterprise](https://www.elastic.co/cloud/enterprise) on 2 servers.

Note that the terraform files and installation script are intentionally basic.

A full production deployment should make use of instance groups, load balancers and other high-availability constructs which have been left out of this setup. See [the Elastic Cloud Enterprise planning docs](https://www.elastic.co/guide/en/cloud-enterprise/1.1/ece-planning.html) for additional details regarding production planning and deployment.

## Usage

First set up a few variables for your own environment by copying `terraform.tfvars.example` to `terraform.tfvars` and replacing the placeholders with values for your own GCP project and location.

Then to start it up, run the following:
```console
> terraform init
> terraform apply

# wait ~60s for instance to finish installing prerequisites

> ./install.sh
```

To tear it down run:

```console
> terraform destroy
```
