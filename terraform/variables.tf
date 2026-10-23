variable "yc_service_account_key_file" {
  description = "Path to the generated Yandex Cloud service account key"
  type        = string
}

variable "yc_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "yc_folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "yc_zone" {
  description = "Default Yandex Cloud availability zone"
  type        = string
}

variable "project_name" {
  description = "Prefix used for infrastructure resource names"
  type        = string
  default     = "project-77"
}

variable "domain_name" {
  description = "Public domain served by the Application Load Balancer"
  type        = string
  default     = "uit14.ru"
}

variable "ssh_username" {
  description = "User created on the web servers"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "SSH public key installed on the web servers"
  type        = string

  validation {
    condition     = length(trimspace(var.ssh_public_key)) > 0
    error_message = "ssh_public_key must not be empty."
  }
}

variable "ssh_allowed_cidrs" {
  description = "IPv4 networks allowed to connect to the web servers over SSH"
  type        = list(string)
}

variable "database_name" {
  description = "PostgreSQL database used by Redmine"
  type        = string
  default     = "redmine"
}

variable "database_username" {
  description = "PostgreSQL user used by Redmine"
  type        = string
  default     = "redmine"
}

variable "database_password" {
  description = "PostgreSQL password supplied through Ansible Vault"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.database_password) >= 12
    error_message = "database_password must contain at least 12 characters."
  }
}

variable "redmine_secret_key_base" {
  description = "Shared Rails secret used by both Redmine instances"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.redmine_secret_key_base) >= 64
    error_message = "redmine_secret_key_base must contain at least 64 characters."
  }
}

variable "redmine_image" {
  description = "Pinned Redmine container image"
  type        = string
  default     = "redmine:6.1.5"
}

