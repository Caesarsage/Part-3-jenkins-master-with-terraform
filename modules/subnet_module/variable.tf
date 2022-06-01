// Default values

variable "public_subnets_count" {
  type = number
  description = "Number of public subnets"
  default = 2
}

variable "private_subnets_count" {
  type = number
  description = "Number of private subnets"
  default = 2
}
variable "vpc_id" {}
variable "public_rt_id" {}
variable "private_rt_id" {}
variable "availability_zone" {
  type        = list
  description = "List of Availability Zones"
}