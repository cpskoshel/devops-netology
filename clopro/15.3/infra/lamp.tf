# Аккаунт для управления группой ВМ
resource "yandex_iam_service_account" "sa-ig" {
  name = "ig-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "ig-editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa-ig.id}"
}

resource "yandex_compute_instance_group" "lamp-ig" {
  name               = "lamp-group"
  folder_id          = var.folder_id
  service_account_id = yandex_iam_service_account.sa-ig.id

  instance_template {
    platform_id = "standard-v1"
    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "fd827b91d99psvq5fjit" # LAMP image
      }
    }

    network_interface {
      network_id = yandex_vpc_network.nuke-net.id
      subnet_ids = [yandex_vpc_subnet.public.id]
      nat        = true
    }

    metadata = {
      user-data = <<-EOF
        #!/bin/bash
        echo "<html><body><h1>Nuke LAMP</h1><img src='https://${yandex_storage_bucket.nuke-bucket.bucket_domain_name}/${yandex_storage_object.nuke-pic.key}'></body></html>" > /var/www/html/index.html
      EOF
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 1
    max_creating    = 3
    max_expansion   = 1
    max_deleting    = 1
  }

  health_check {
    http_options {
      port = 80
      path = "/"
    }
  }

  application_load_balancer {
    target_group_name = "lamp-alb-tg"
  }
}

# Группа бэкендов
resource "yandex_alb_backend_group" "lamp-bg" {
  name = "lamp-backend-group"

  http_backend {
    name             = "lamp-http-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_compute_instance_group.lamp-ig.application_load_balancer[0].target_group_id]
    
    # Проверка состояния
    healthcheck {
      timeout             = "1s"
      interval            = "1s"
      healthy_threshold   = 2
      unhealthy_threshold = 2
      http_healthcheck {
        path = "/"
      }
    }
  }
}
