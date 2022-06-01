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
  nat_id = "${module.nat_gateway_id.nat_id}"
}

module "subnet_module" {
  source = "./modules/subnet_module"
  vpc_id = "${module.vpc_module.vpc_id}"
  availability_zone = "${var.availability_zone}"
  public_rt_id = "${module.route_table_module.public_rt_id}"
  private_rt_id = "${module.route_table_module.private_rt_id}"
}

module "elastic_ip_module" {
  source = "./modules/elastic-ip_module"
  vpc_name = "${var.vpc_name}"
}

module "nat_gateway_id" {
  source = "./modules/nat-gateway_module"
  eip_nat_id = "${module.elastic_ip_module.eip_nat_id}"
  subnet_public = "${module.subnet_module.subnet_public}"
  vpc_name = "${var.vpc_name}"
}

module "baston_host_sg" {
  source = "./modules/security-group_module/bastion_security_module"
  vpc_name = "${var.vpc_name}"
  vpc_id = "${module.vpc_module.vpc_id}"
}

module "alb_jenkins_sg" {
  source = "./modules/security-group_module/jenkins_elb_security_module"
  vpc_id = "${module.vpc_module.vpc_id}"
}

module "jenkins_master_sg" {
  source = "./modules/security-group_module/jenkins_master_security_module"
  vpc_id = "${module.vpc_module.vpc_id}"
  vpc_name = "${var.vpc_name}"
  alb_jenkins_sg_id = "${module.alb_jenkins_sg.alb_jenkins_sg_id}"
  baston_host_sg_id = "${module.baston_host_sg.baston_host_sg_id}"
}

module "bastion_host" {
  source = "./modules/baston_module"
  baston_host_sg_id = "${module.baston_host_sg.baston_host_sg_id}"
  subnet_public = "${module.subnet_module.subnet_public}"
}

module "jenkins_master" {
  source = "./modules/jenkins-master_module"
  subnet_private = "${module.subnet_module.subnet_private}"
  subnet_public = "${module.subnet_module.subnet_public}"
  jenkins_master_sg_id ="${module.jenkins_master_sg.jenkins_master_id}"
  alb_jenkins_sg_id = "${module.alb_jenkins_sg.alb_jenkins_sg_id}"
  vpc_id = "${module.vpc_module.vpc_id}"
}