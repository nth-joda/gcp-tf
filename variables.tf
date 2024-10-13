variable "project" {
}

variable "credentials_file" {}

variable "region" {
  default = "us-central1"
}

## ======= GC
variable "zone" { # biến vùng của các GC
  default = "us-central1-c"
}
variable "boot_image" { # biến boot_image
  default = "debian-cloud/debian-11"
}
variable "machine_type" { # biến độ mạnh của máy
  default = "f1-micro"
}
