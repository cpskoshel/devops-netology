data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

# ВМ в публичной подсети (Бастион)
resource "yandex_compute_instance" "public-vm" {
  name = "public-vm"
  zone = var.default_zone

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }

  metadata = {
    user-data = file("./cloud-init.yml")
  }
}

# ВМ в приватной подсети
resource "yandex_compute_instance" "private-vm" {
  name = "private-vm"
  zone = var.default_zone

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  scheduling_policy {
    preemptible = true
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
    nat       = false # Только внутренний IP
  }

  metadata = {
    user-data = file("./cloud-init.yml")
  }
}