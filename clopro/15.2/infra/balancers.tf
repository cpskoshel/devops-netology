resource "yandex_lb_target_group" "nlb-tg" {
  name      = "lamp-nlb-tg-manual"
  region_id = "ru-central1"

  dynamic "target" {
    for_each = yandex_compute_instance_group.lamp-ig.instances
    content {
      subnet_id = yandex_vpc_subnet.public.id
      address   = target.value.network_interface.0.ip_address
    }
  }
}

resource "yandex_lb_network_load_balancer" "nlb" {
  name = "nuke-nlb"
  
  listener {
    name = "http"
    port = 80
    external_address_spec { ip_version = "ipv4" }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.nlb-tg.id
    healthcheck {
      name = "http"
      http_options { 
        port = 80
        path = "/"
      }
    }
  }
}

# ПРИКЛАДНОЙ БАЛАНСИРОВЩИК (ALB)

resource "yandex_alb_backend_group" "alb-bg" {
  name = "lamp-alb-bg"

  http_backend {
    name             = "backend-1"
    port             = 80
    target_group_ids = [yandex_compute_instance_group.lamp-ig.application_load_balancer.0.target_group_id]
    
    healthcheck {
      timeout  = "1s"
      interval = "1s"
      http_healthcheck { 
        path = "/" 
      }
    }
  }
}

resource "yandex_alb_http_router" "router" { 
  name = "nuke-router" 
}

resource "yandex_alb_virtual_host" "vhost" {
  name           = "nuke-host"
  http_router_id = yandex_alb_http_router.router.id
  route {
    name = "route"
    http_route {
      http_route_action { 
        backend_group_id = yandex_alb_backend_group.alb-bg.id 
      }
    }
  }
}

resource "yandex_alb_load_balancer" "alb" {
  name       = "nuke-alb"
  network_id = yandex_vpc_network.nuke-net.id

  allocation_policy {
    location { 
      zone_id   = "ru-central1-a" 
      subnet_id = yandex_vpc_subnet.public.id 
    }
  }

  listener {
    name = "http-listener"
    endpoint {
      address { 
        external_ipv4_address {
        } 
      }
      ports   = [80]
    }
    http { 
      handler { 
        http_router_id = yandex_alb_http_router.router.id
      } 
    }
  }
}