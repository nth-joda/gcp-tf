# Giới thiệu Terraform on GCP: Deploy - Change - Destroy

## 0. Install terraform (on MacOS):

```sh
brew tap hashicorp/tap
```

```sh
brew install terraform
```

(Other OS install, check: https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli)

## 1. Build Infrastructure (on GPC)

### 1.1 Prerequisites:

- A Google Cloud Platform account
- <details>
    <summary>The gcloud CLI installed locally</summary>
    
    #### 0. Install python  version from 3.8 to 3.12
    ```sh
    brew install python@3.11
    ```

  #### 1. Install google-cloud-sdk (có CLI trong đó, cho dễ)

  ```sh
  brew install --cask google-cloud-sdk
  ```

  _Thấy v là ngon :_

  ```
  Welcome to the Google Cloud CLI!

  Your current Google Cloud CLI version is: 496.0.0
  The latest available version is: 496.0.0
  ```

  </details>

- Terraform 0.15.3+ installed locally. (Above step)

### 1.2 Setup GCP project

- Goto **GCLound Console** > Cloud Resource Manager > Create a project
- Enable Google Compute Engine API in **GCLound Console** at https://console.cloud.google.com/apis/library/compute.googleapis.com?project=pk-research&flow=gcp (có yêu cầu billing, có tốn tiền, có tốn tiền, CÓ TỐN TIỀN !!! )

### 1.3 Vào việc: tạo file `main.tf`

_(Nhớ install extension `HashiCorp Terraform` cho dễ code)_

##### 1. Deploy Infrastructure:

- Tạo và ghi vào file `main.tf`:

```tf

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
```

- <details>
    <summary>Login</summary>

        ```sh
            gcloud auth application-default login
        ```

  _Sẽ thấy như v, nó chỉ chổ nó lưu credentials để dùng sau này:_

  ```sh
      Your browser has been opened to visit:

      https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=764086051850-6qr4p6gpi6hn506pt8ejuq83di341hur.apps.googleusercontent.com&redirect_uri=http%3A%2F%2Flocalhost%3A8085%2F&scope=openid+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloud-platform+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fsqlservice.login&state=LFnr8kqhFNXf4ZL5id3cCu5ssx2FGu&access_type=offline&code_challenge=DNn9pk9I1gXJc3ImSlrjkPhBoIfHis2r8B0qrVO_g0c&code_challenge_method=S256


      Credentials saved to file: [/Users/nthdac/.config/gcloud/application_default_credentials.json]
  ```

</details>

- <details> <summary>Install các resource, provider ... </summary>

  ```sh
    terraform init
  ```

  _Thấy v là ngon lành cành đào: `Terraform has been successfully initialized!`_

  </details>

- <details><summary>Format & validate config</summary>

  ```sh
  terraform fmt
  ```

  ```sh
  terraform validate
  ```

  _Ngon lành là khi: `Success! The configuration is valid.`_

  </details>

- <details> 
        <summary>Apply các config lên GCP project</summary>
          
        ```sh
        terraform apply
        ```

  _Ko thấy v là mệt gòy áh (¬‿¬) : `Apply complete! Resources: ... added, 0 changed, 0 destroyed.`_

  Apply xong thì tf ghi data vào file `terraform.tfstate`, file này lưu lại các resource mà tf đang quản lý (Có cả các **thông tin nhạy cảm**).

  _Docs TF khuyên ở **production** dùng `HCP Terraform or Terraform Enterprise` để lưu remotely_

  Có thể xem các resource mà TF quản lý qua CLI:

  ```sh
  terraform show
  ```

  _Nó trả về tương tự như này:_

  ```
  # google_compute_network.vpc_network:
  resource "google_compute_network" "vpc_network" {
    auto_create_subnetworks         = true
    delete_default_routes_on_create = false
    enable_ula_internal_ipv6        = false
    id                              = "projects/pk-research/global/networks/terraform-network"
    mtu                             = 0
    name                            = "terraform-network"
    project                         = "pk-research"
    routing_mode                    = "REGIONAL"
    self_link                       = "https://www.googleapis.com/compute/v1/projects/pk-research/global/networks/terraform-network"
  }
  ```

  Lên GCloud Console > VPC network sẽ thấy 1 cái network tên là `terraform-network` giống như mình định nghĩa ở cái chổ `name = "terraform-network"`
    </details>

##### 2. Change Infrustructure

Sau khi đã deploy thành công ở mục 1, h mình apply từ từ các thay đổi nè (làm 1 lần, nó bug ko biết đường mò. Build dần dần cũng rất practical, có system nào mà ko upgrade, chỉnh sửa đâu... h dô he)

- Tạo thử 1 resource GC vào file `main.tf`:

```tf
# Tạo 1 máy ảo tên là "terraform-instance"
# Định nghĩa chi tiết các property của block GC mình coi ở đây he: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance?product_intent=terraform
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance" # tên của component
  machine_type = "f1-micro"           # property của GC, độ mạnh của máy ảo
  zone         = "us-central1-a"      # khu vực của máy

  boot_disk { # định nghĩa cấu hình của máy: OS, size ..., ví dụ con này chạy linux debian
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {                                 # định nghĩa con này nằm trong network nào
    network = google_compute_network.vpc_network.name # chổ này trỏ tới cái network hồi nãy mình định nghĩa nè
    access_config {                                   # chổ này kiểu config để coi IP nào được ra internet, bỏ obj thì nó ko kết nối đc internet
      # nhưng mà dù gắn vô, ko có property nào, thì nó cũng tự gen ra và nó kết nối đc internet (vd như v là này kết nối internet đc nè)
    }
  }
}

```

- Gòy, giờ để apply các thay đổi này thì mình chạy lại các lệnh:

```sh
terraform fmt
```

```sh
terraform validate
```

```sh
terraform apply
```

Chạy xong thì xem lại thử coi `terraform show` nó print ra gì. Cũng nhớ lên GCloud Console double check lại nha, coi `Compute Engine` có cái máy ảo mình tạo chưa, thông số đúng ko? (ko đúng thì sợ ma nha, thỉnh thầy về liền)

- 2 loại thay đổi (update vs Destroy&Add):

  Gòy giờ thử make a change, set các tag vào cái máy ảo vừa tạo bằng cách thêm property `tags = ["web", "dev"]`, gòy apply cái change này đi. Có phải thấy là nói nói v hông `Apply complete! Resources: 0 added, 1 changed, 0 destroyed.`. Nghĩa là gì:

  `terraform apply` vừa chạy nó tạo ra 1 thay đổi mà 0 có resource nào thêm mới, có 1 resource thay đổi, 0 có resource bị xoá đi. Hồi đầu mình apply nó nói ` 1 added, 0 changed, 0 destroyed` đúng ko, 1 đó là resource network é.

  Gòy giờ thử đổi từ linux debian sang ubuntu thử (ubuntu có tính phí, ko demo đâu hehe.. ). Nhưng mà ý chổ này là khi đổi image thì cái engine cũ sẽ bị xoá đi vào tạo lại cái mới. Tức là có 1 vài thay đổi nó bược phải **destroyed resource cũ và added resource mới**

##### 3. Destroy Infrustructure

- Dữ án fail, đóng cửa vô chùa tu thì xoá sạch sẽ các resource bằng cách nào. `terraform destroy` sẽ **terminate** các resources mà nó quản lý trong project này (project được xem là file main.tf, file này mà ko giống lúc chạy thì ăn c\*c x2, nhớ Version Control file này).

- Lúc chạy thì nó sẽ hỏi: "t sẽ phá huỷ các thứ sau ...abcxyz... m chịu hôk, chịu thì gõ `yes`". Nó sẽ gạch đầu dòng đỏ `-` các thứ mà nó xoá, nó có summary sẽ xoá bao nhiêu resources như này nè: `Plan: 0 to add, 0 to change, 2 to destroy.`

_**Có thể bạn đã biết, hoặc ko cần biết**: Cái network sẽ ko bị destroyed cho đến khi ko còn running instance nào trong network đó nữa. Nghĩa là các instances bị xoá trước, và network bị xoá sau cùng_

- Nãy h xoá infrustruction hoy, còn billing nữa:
  - Lên GCloud Console > 'APIs & Services' > 'Compute Engine API' > Disable API đi.
  - Gòy vô 'Billing' > 'Manage Billing Account' > Disable Billing trong cái bảng `Projects linked to this billing account` > Xong nhấn cái nút 'Close Billing Account' ở trên cùng dưới thanh tìm kiếm á
  - Gòy vô tab 'Payment method' > Remove cái thẻ ra nhé. Xong òi đó, cạo đầu đi vô chùa nè

### 1.4 Quản lý các biến sử dụng trong `main.tf`

với mục 1.3 là xài ngon lành cành sữa đậu nành gòy, giờ là thí dụ system lớn quá, tạo ra nhiều resource thì các property chug của resource mình nên để trong 1 biến, để sau này có chỉnh sữa đỡ cực và đỡ bug. Ví dụ các máy ảo ở zone us chạy debian, mốt sang sang muốn đổi qua zone asian, chạy ubuntu thì phải sửa hết tất cả các instance... Thay vào đó, mình tạo các biến như image, zone ... các property của các resource sẽ trỏ vào biến này. Usecase nó là v, h mình làm sao?

- Tạo thêm 1 file `variables.tf` giả sử để cùng cấp vs file `main.tf` nhoa.

- Định nghĩa thử các biến:

```sh
variable "project" {}

variable "credentials_file" {}

variable "region" {
  default = "us-central1"
}

## ======= GC
variable "zone" { # biến vùng của các GC
  default = "us-central1-c"
}
variable "toot_image" { # biến boot_image
  default = "debian-cloud/debian-11"
}
variable "machine_type" { # biến độ mạnh của máy
  default = "f1-micro"
}

```

Để sử dụng các biến đã tạo: `var.<tên_biến>`, ví dụ `var.machine_type` sẽ trả về "f1-micro"

Đổi các giá trị property của GC trong file `main.tf` bằng các biến, gòy apply thử (nhớ gắn lại 'Billing' và enable lại 'Compute Engine API' nếu hồi nãy gỡ gòy):

```tf
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
```

- Nó hay ha, mình no chỉ định đường dẫn đến file variables mà nó tự biết luôn. Cơ chế là nó sẽ load tất cả files đuôi tf trong folder project. keyword `variable` nó sẽ processed trước, r mới tới các keywork khác, như resource. Tức là chổ này mình có thể chia ra nhiều file variable để quản lý.

- Nưu Ý: Các biến nhạy cảm như: ProjectID, credentials, ... nên lưu ở 1 file riêng và ko Version Control các file này (coi chừng như vụ FSoft).

- Nó có offer cho mình 1 file tên là `terraform.tfvars` hoặc các file tên gì cũng đc, miễn đuôi `.auto.tfvars` để mình định nghãi các biến theo kiểu:

```tfvars
project                  = "<PROJECT_ID>"
credentials_file         = "<FILE>"
```
