variable "key_name" {
    type    = string
    default = "surim"
}

variable "igw" {
    type     = string
    default  = "igw-b2f946da"
}

variable "my_access_key" {
    type    = string
}

variable "my_secret_key" {
    type    = string
}

variable "my_region" {
    type    = string
    default = "ap-northeast-2"
}

variable "image_id_front" {
    type    = string
    default = "ami-0718a49b3b9b8ec56"
}

variable "image_id_back" {
    type    = string
    default = "ami-0673a96e1c4e807fb"
}

variable "target_group_path" {
    type    = string
    default = "/"
}

variable "db_username" {
    type    = string
}

variable "db_password" {
    type    = string
}

variable "db_port" {
    type    = string
    default = "3306"
}
