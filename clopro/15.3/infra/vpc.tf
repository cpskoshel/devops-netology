# VPC
resource "yandex_vpc_network" "nuke-net" {
  name = "nuke-network"
}

# Публичная подсеть
resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.nuke-net.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Приватная подсеть с привязкой к таблице маршрутов
resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.nuke-net.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.nat-rt.id
}

# Таблица маршрутизации для приватной сети
resource "yandex_vpc_route_table" "nat-rt" {
  network_id = yandex_vpc_network.nuke-net.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.254"
  }
}

# NAT
resource "yandex_compute_instance" "nat-instance" {
  name = "nat-instance"
  zone = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1" # Специальный образ NAT-gateway
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    ip_address = "192.168.10.254"
    nat        = true # публичный IP для выхода в инет
  }

  metadata = {
    user-data = file("./cloud-init.yml")
  }
}
