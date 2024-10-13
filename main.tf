# terraform block định nghĩa provider: `Google`, AWS ....
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google" # source định ngĩa nơi install provider
      version = "4.51.0"           # version của provider
    }
  }
}

provider "google" {       # the plugin
  project = "pk-research" # replace your <project_id>
}

# resource định nghĩa 1 thành phần (component) của infrastructure/system
# Syntax: `resource <resource_type> <resource_variable_name>`
# ví dụ: resource `google_compute_network` tên biến là `vpc_network`
# <resource_variable_name> dùng để truy vấn trong file này, name = "terraform-network" tên thật của resource trên GCP
resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}


# Tạo 1 máy ảo tên là "terraform-instance"
# Định nghĩa chi tiết các property của block GC mình coi ở đây he: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance?product_intent=terraform
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance" # tên của component
  machine_type = var.machine_type     # property của GC, độ mạnh của máy ảo
  zone         = var.zone             # khu vực của máy
  tags         = ["web", "dev"]
  boot_disk { # định nghĩa cấu hình của máy: OS, size ..., ví dụ con này chạy linux debian
    initialize_params {
      image = var.boot_image
    }
  }

  network_interface {                                 # định nghĩa con này nằm trong network nào
    network = google_compute_network.vpc_network.name # chổ này trỏ tới cái network hồi nãy mình định nghĩa nè
    access_config {                                   # chổ này kiểu config để coi IP nào được ra internet, bỏ obj thì nó ko kết nối đc internet
      # nhưng mà dù gắn vô, ko có property nào, thì nó cũng tự gen ra và nó kết nối đc internet (vd như v là này kết nối internet đc nè) 
    }
  }
}
