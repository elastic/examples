# A sample installation of Elastic Cloud Enterprise on GCP

## Details

This tree provides a basic test bed for an installation of [Elastic Cloud Enterprise](https://www.elastic.co/cloud/enterprise) on 3 servers.

Note that the terraform files and installation script are intentionally basic.

A full production deployment should make use of instance groups, load balancers and other high-availability constructs which have been left out of this setup. See [the Elastic Cloud Enterprise planning docs](https://www.elastic.co/guide/en/cloud-enterprise/1.1/ece-planning.html) for additional details regarding production planning and deployment.

## Prerequisites on your machine
- Terraform v0.12.x
- Ansible

## Usage

First set up a few variables for your own environment by copying `terraform.tfvars.example` to `terraform.tfvars` and replacing the placeholders with values for your own GCP project and location.

Then to start it up, run the following:
```console
> terraform init
> terraform apply
```

Wait for the installation to complete, and hurah! you now have a 3-instance ece installation ready on GCP!

You'll be presented with the URL to log in to ece.
The admin password will be presented above as part of the running ansible flow like this:
```console
null_resource.run-ansible (local-exec): ok: [some-instance-public-dns-address] => {
null_resource.run-ansible (local-exec):     "msg": "Adminconsole password is: <PASSWORD> "
null_resource.run-ansible (local-exec): }
```


To tear it down run:

```console
> terraform destroy
```
