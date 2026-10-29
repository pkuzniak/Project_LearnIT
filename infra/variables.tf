variable "project_name" {
  description = "Project name used for resource names and tags."
  type        = string
  default     = "learnit"
}

variable "instance_type" {
  description = "EC2 instance type for the application."
  type        = string
  default     = "t3.micro"
}

variable "admin_cidr" {
  description = "Public IPv4 address of the Dell network in CIDR notation."
  type        = string

  validation {
    condition = (
      can(cidrnetmask(var.admin_cidr)) &&
      can(regex("/32$", var.admin_cidr))
    )
    error_message = "Use a single public IPv4 address with a /32 suffix."
  }
}
