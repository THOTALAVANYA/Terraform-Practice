variable "ami" {
    type = string
    default = ""
    description = "vpc with custon n/w"
}

variable "instance_type" {
    default = ""
    type = string 
}

variable "key_name" {
    type = string
    default = ""
}