variable "ami" {
  type    = string
  default = ""
}

variable "instance_type" {
  type    = string
  default = ""
}

variable "sandboxes" {
  type    = list(string)
  default = [ ]
}

variable "iam_users" {
  type    = list(string)
  default = [ ]
  description = "IAM users"
}
