terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.209.0"
    }
  }
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2604-lts"
}

resource "yandex_compute_disk" "disk" {
  name     = var.disk_name
  type     = var.disk_type
  zone     = var.zone
  image_id = data.yandex_compute_image.ubuntu.image_id
  size     = var.disk_size
}

resource "yandex_compute_instance" "vm" {
  name = var.vm_name
  zone = var.zone

  resources {
    cores  = var.cpu
    memory = var.mem
  }

  boot_disk {
    disk_id = yandex_compute_disk.disk.id
  }

  network_interface {
    subnet_id = var.subnet_id
  }

  metadata = {
    ssh-keys = "testUser:${var.ssh_pub}"
  }
}
