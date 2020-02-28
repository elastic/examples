# A sample installation of Elastic Cloud Enterprise on AWS

## Details

This tree provides a basic example installation of [Elastic Cloud Enterprise](https://www.elastic.co/cloud/enterprise) on 3 servers using terraform & ansible.

Note that the terraform files and installation script are intentionally basic.

A full production deployment should make use of auto scaling groups, load balancers and other high-availability constructs which have been left out of this setup. See [the Elastic Cloud Enterprise planning docs](https://www.elastic.co/guide/en/cloud-enterprise/current/ece-planning.html) for additional details regarding production planning and deployment.

## Prereqs on your machine
- Terraform v0.12.x
- Ansible

## Usage

First set up a few variables for your own environment by copying `terraform.tfvars.example` to `terraform.tfvars` and replacing the placeholders with values for your own AWS account and location.

Then to start it up, run the following:

```console
> terraform init
> terraform apply
```

Wait for the installation to complete, and hurah! you now have a 3-instance ece installation ready on AWS!

You'll be presented with the URL to log in to ece.
The admin password will be presented above as part of the running ansible flow like this:
```
null_resource.run-ansible (local-exec): ok: [some-instance-public-dns-address] => {
null_resource.run-ansible (local-exec):     "msg": "Adminconsole password is: <PASSWORD> "
null_resource.run-ansible (local-exec): }
```

To tear it down run:

```console
> terraform destroy
```
