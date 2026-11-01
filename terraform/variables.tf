variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "az" {
  type    = string
  default = "ap-south-1a"
}

variable "student_name" {
  type        = string
  description = "Your name, used for the Student tag"
}

variable "my_ip_cidr" {
  type        = string
  description = "Your current public IPv4 as /32, for example 203.0.113.25/32"
}

variable "key_name" {
  type        = string
  default     = "ewb-lab"
  description = "Existing EC2 key pair created in the console (the .pem stays on your laptop)"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "enable_peering" {
  type        = bool
  default     = false
  description = "false = baseline (no peering, ping fails). true = create peering and routes."
}
