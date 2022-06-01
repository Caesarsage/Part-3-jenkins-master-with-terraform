variable "cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC cidr block"
}
variable "vpc_name" {
  type        = string
  description = "VPC name"
}