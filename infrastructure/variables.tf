
variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "spring-boot-app" # Default project name

}

variable "environment" {
  description = "The project environment"
  type        = string
  default     = "dev" # Default environment

}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16" # Default CIDR block for the VPC
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true # Default to true
}

variable "enable_dns_support" {
  description = "Enables DNS support in the VPC"
  type        = bool
  default     = true # Default to true
}

variable "extra_tags" {
  description = "Extra tag to be applied to resources"
  type        = any
  default     = {}
}

#Access
variable "define_admin_users" {
  description = "Whether to define admin users"
  type        = bool
  default     = false
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Enable admin permissions for the cluster creator"
  type        = bool
  default     = false
}

variable "access_entries" {
  description = "Map of access entries to add to the cluster"
  type        = any
  default     = {}
}


#JENKINS

variable "jenkins_admin_username" {
  description = "The username for the Jenkins admin user"
  type        = string
  default     = "controller.admin.username" # Default Jenkins admin username
  sensitive = true
}

variable "jenkins_admin_password" {
  description = "The password for the Jenkins admin user"
  type        = string
  default     = "controller.admin.password" # Default Jenkins admin password
  sensitive = true
}