# Workflow for Provisioning a Server on DigitalOcean with Terraform and Ansible

This repository is a quickstart to get a single 1GB 1vCPU [Droplet](https://www.digitalocean.com/pricing/) up and running on DigitalOcean using [Terraform](https://www.terraform.io/) and [Ansible](https://www.ansible.com/). You can use it as a jumping off point to build out your infrastructure.

The setup here riffs on this [really cool project](https://github.com/do-community/terraform-ansible-demo) that shows you how to use Terraform and Ansible to provision two DO Droplets and a Load Balancer, with Nginx installed on both servers. It also mirrors the functionality of DO's recommended [Ubuntu 18.04 server setup instructions](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-18-04). So it's a great starting point if you want to work with DO tutorial prerequisites! 

Make sure that you enter **your own information** into `terraform.tfvars`. For this file, you'll need:
- An [SSH key](https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/) on your local computer that's associated with your DigitalOcean account. To get the fingerprint of this key, run: `ssh-keygen -E md5 -lf ~/.ssh/id_rsa.pub | awk '{print $2}'`
- A [personal access token](https://www.digitalocean.com/docs/api/create-personal-access-token/).

## Step 1 — Clone Repo

Here's how to use this repo.

Clone it:

```command
$ git clone https://github.com/katjuell/do-terraform-ansible.git do_setup
```
Move to the directory:

```command
$ cd do_setup
```

## Step 2 — Add Your Info to the Appropriate Files

Add your SSH fingerpint and DigitalOcean access token to `terraform.tfvars`:

```command
$ vi terraform.tfvars
```
```
<<<<<<< HEAD
do_token = "" #fill this in with your own information
ssh_fingerprint = "" #fill this in with your own information
=======
do_token = "" #fill this in
ssh_fingerprint = "" #fill this in
>>>>>>> upstream/master
```
If you want to change the size of the resources in `terraform.tf` you should feel free. Also feel free to rename your Droplet — `test` isn't very descriptive:

```
...
# create smallest droplet
resource "digitalocean_droplet" "test" {
  image    = "ubuntu-18-04-x64"
  name     = "test"
  region   = "nyc3"
  size     = "s-1vcpu-1gb"
  ssh_keys = ["${var.ssh_fingerprint}"]
}
...
```
In `ansible.yml`, you'll also want to create a username other than `sammy`:

```
...
   - name: create user 'sammy'
      user: 
          name: sammy 
          append: yes 
          state: present 
          createhome: yes 
          shell: /bin/bash

    - name: allow 'sammy' to have passwordless sudo
      lineinfile:
        dest: /etc/sudoers
        line: 'sammy ALL=(ALL) NOPASSWD: ALL'
        validate: 'visudo -cf %s'

    - name: set up authorized keys for 'sammy' user
      authorized_key: user=sammy key="{{item}}"
      with_file:
        - ~/.ssh/id_rsa.pub
...
```

## Step 3 — Create Your Infrastructure and Configure Your Server

You are ready to start!

Initialize Terraform:

```command
$ terraform init
```
Test the plan for provisioning your infrastructure:

```command
$ terraform plan
```
Create your server:

```command
$ terraform apply
```
Run the playbook to create your user and configure your firewall with UFW:

```command
$ ansible-playbook -i inventory ansible.yml
```
Your `terraform.tfstate` file will have your IP address; you can also get it from the DO Control Panel.

SSH into your server as your non-root user, and change your password:

```command
$ sudo passwd sammy
```
You are good to go!
