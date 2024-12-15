#lb.tf
resource "yandex_lb_target_group" "lamp_target_group" {
  name = "lamp-target-group"

  dynamic "target" {
    for_each = yandex_compute_instance_group.lamp_group.instances
    content {
      address   = target.value.network_interface[0].ip_address
      subnet_id = yandex_vpc_subnet.subnet.id
    }
  }
}

resource "yandex_lb_network_load_balancer" "lb" {
  name = "lamp-load-balancer"

  listener {
    name        = "listener-http"
    port        = 80
    target_port = 80
    protocol    = "tcp"
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.lamp_target_group.id

    healthcheck {
      name = "http-check"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}
