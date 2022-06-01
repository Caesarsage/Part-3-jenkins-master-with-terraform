# Creating Jenkins instance with terraform

## Steps

- Take note of the ami name of the baked image from Challenge 2.
- Create network infrastructure (VPC, public and private subnets, network gateways, route tables and route table association)..
  - Create VPC
  - Create Internet gateway
  - Create custom route table
  - Create our subnets
  - Associate subnets with route table
- Create Security Groups for
  - Bastion
  - Jenkins load balancer
  - Jenkins security group
- Create a bastion-host server.
- Create jenkins server and only grant ssh access to bastion host.
- Setup an application load balancer (ALB) to access the jenkins server

### Provisioning an AWS VPC (Virtual private cloud)

We will be deploying our Jenkins cluster inside a VPC within private subnets; This is to allow us have full control of the network topology, we will create a VPC from scratch to isolate our Jenkins cluster from the application.

The VPC is divided into subnets which can either be

- public or
- private subnets

Routing rules between subnet allows traffic to go through either an internet gateway or NAT gateway.

### Initialize terraform and file Structure

Folder and Files stuctures

```
--- modules
--- main.tf
--- variables.tf
--- variables.tfvars
--- README.md
--- .gitignore

```

The main.tf file will serve as our entry point. We start by providing the following code inside to configure our provider to aws and authenticate us.

```
provider "aws" {
  region     = "${var.aws_profile[0]}"
  access_key = "${var.aws_profile[1]}"
  secret_key = "${var.aws_profile[2]}"
}

```

Now , run the following in your terminal to initial your provider

_RUN_
run the following in your terminal

> > terraform init
> > terraform plan --var-file="variables.tfvars"
> > terraform apply --var-file="variables.tfvars"

<img src="assets/first-run.PNG" alt="">

NB - We will constantly update this root main.tf file.

#### Creating a VPC

Enter the following code in **module/vpc_module/main.tf** saves its variable and output in the variable and output file inside the module folder

```
resource "aws_vpc" "vpc-module" {
  cidr_block = "${var.cidr_block}"

  tags = {
    Name = "${var.vpc_name}"
  }
}
```

**module/vpc_module/output.tf**

```
output vpc_id {
  value       = "${aws_vpc.vpc-module.id}"
}
```

**module/vpc_module/variable.tf**

```
variable "cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC cidr block"
}
variable "vpc_name" {
  type        = string
  description = "VPC name"
}
```

_RUN_
>> Terraform init
>> terraform plan --var-file="variables.tfvars"
>> terraform apply --var-file="variables.tfvars"

<img src="assets/vcp-created.PNG" alt="vpc" />

### Create an internet gate way

Enter the following code in **module/subnet_module/main.tf** and saves its variable and output in the variable and output file inside the module folder

```
resource "aws_internet_gateway" "igw" {
  vpc_id = "${var.vpc_id}"

  tags = {
    Name = "igw_${var.vpc_name}"
  }
}
```

### Custom route table

Enter the following code in **module/route-table_module/main.tf** and saves its variable and output in the variable and output file inside the module folder

```
resource "aws_route_table" "public_rt" {
  vpc_id = "${var.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.igw_id}"
  }
  tags = {
    Name = "public_rt_${var.vpc_name}"
  }
}

```

### Create our subnets and associate with route tables

Enter the following code in **module/route-table_module/main.tf** and saves its variable and output in the variable and output file inside the module folder

```
resource "aws_subnet" "public_subnet" {
  vpc_id                         = "${var.vpc_id}"
  cidr_block                     = "10.0.${count.index * 2 + 1}.0/24"
  availability_zone              = element(var.availability_zone, count.index)
  map_public_ip_on_launch         = true

  count                          = "${var.public_subnets_count}"

  tags = {
    Name = "public_10.0.${count.index *2 + 1}.0_${element(var.availability_zone, count.index)}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                         = "${var.vpc_id}"
  cidr_block                     = "10.0.${count.index * 2}.0/24"
  availability_zone              = element(var.availability_zone, count.index)
  map_public_ip_on_launch         = false

  count                          = "${var.private_subnets_count}"

  tags = {
    Name = "private_10.0.${count.index *2}.0_element(var.availability_zone, count.index)"
  }
}

# assign public subnet to the route table
resource "aws_route_table_association" "subnet-public-association" {
  count          = "${var.public_subnets_count}"
  subnet_id      = element("${aws_subnet.public_subnet.*.id}", count.index)
  route_table_id = "${var.public_rt_id}"
}

# assign private subnet to the route table
 resource "aws_route_table_association" "subnet-private-association" {
   subnet_id      = "${aws_subnet.subnet_private.id}"
   route_table_id = "${var.route_table_id}"
 }

```

#### Update the main.tf file as follow and run the following command

```
provider "aws" {
  region     = "${var.aws_profile[0]}"
  access_key = "${var.aws_profile[1]}"
  secret_key = "${var.aws_profile[2]}"
}

# vpc
module "vpc_module" {
  source = "./modules/vpc_module"
  vpc_name = "${var.vpc_name}"
}
module "igw_id" {
  source = "./modules/internet-gateway_module"
  vpc_id = "${module.vpc_module.vpc_id}"
  vpc_name = "${var.vpc_name}"
}
module "route_table_module" {
  source = "./modules/route-table_module"
  vpc_id = "${module.vpc_module.vpc_id}"
  igw_id = "${module.igw_id.igw_id}"
  vpc_name = "${var.vpc_name}"
}

module "subnet_module" {
  source = "./modules/subnet_module"
  vpc_id = "${module.vpc_module.vpc_id}"
  availability_zone = "${var.availability_zone}"
  public_rt_id = "${module.route_table_module.public_rt_id}"
}
```

### Security groups

Create security groups folder for bastion, jenkins_alb, jenkins_master inside the **module/security-group_module**

- **module/security-group_module/bastion_security_module**

```

```

- **module/security-group_module/jenkins_alb_security**

```

```

- **module/security-group_module/jenkins_master_security**

```

```

### Create a bastion-host server

Enter the following code in **module/bastion_module/main.tf** and saves its variable and output in the variable and output file inside the module folder

```

```

### Create jenkins server

Enter the following code in **module/jenkins-master_module/main.tf** and saves its variable and output in the variable and output file inside the module folder

```

```

>> terraform init
>> terraform plan --var-file="variables.tfvars"
>> terraform apply --var-file="variables.tfvars"

<img src="assets/running-3.PNG" alt="jenkins-bastion-instance" >

**ssh into the instance by host forwarding**

>> ssh -L 4000:10.0.0.154:22 -i terraform-p-key
>> ec2-user@44.201.224.222

<img src="./assets/terminal-4.PNG" alt="jenkins-bastion-instance" >

### Setup an application load balancer (ALB) to access the jenkins server

Enter the following code in **module//main.tf** and saves its variable and output in the variable and output file inside the module folder

```
```

### Infrastructure diagram

<img src="./assets/terraform-jenkins.drawio.png" alt="infrastructure diagram"  />
