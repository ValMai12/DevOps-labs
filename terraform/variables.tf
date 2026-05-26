variable "student_ssh_public_key" {
  description = "Public SSH key for the ansible user"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE+Z4hHiKoZmtfJFYFC+w/qzskTZH1pT20fsvbc8Nh/N lab4"
}

variable "variant_number" {
  description = "Student variant number"
  type        = number
  default     = 12
}

variable "app_port" {
  description = "Application port according to the variant"
  type        = number
  default     = 3000
}

variable "db_port" {
  description = "MariaDB port"
  type        = number
  default     = 3306
}
