resource "yandex_vpc_network" "network" {
  name = "lamp-network"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "lamp-subnet"
  network_id     = yandex_vpc_network.network.id
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_compute_instance_group" "lamp_group" {
  name               = "lamp-instance-group"
  folder_id          = var.folder_id
  service_account_id = var.service_account_id

  instance_template {
    platform_id = "standard-v1"
    resources {
      cores  = 2
      memory = 2
    }

    boot_disk {
      initialize_params {
        image_id = "fd827b91d99psvq5fjit" 
      }
    }

    network_interface {
      subnet_ids = [yandex_vpc_subnet.subnet.id]
      nat        = true
    }

    metadata = {
      user-data = file("${path.module}/cloud-init.yaml")
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  deploy_policy {
    max_unavailable = 1
    max_creating    = 1
    max_expansion   = 1
    max_deleting    = 1
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  health_check {
    http_options {
      port = 80
      path = "/"
    }
    interval = 5
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}
