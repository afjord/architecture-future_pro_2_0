output "instance_id" {
  value       = yandex_compute_instance.vm.id
  description = "Идентификатор виртуальной машины"
}

output "instance_ip" {
  value       = yandex_compute_instance.vm.network_interface[0].ip_address
  description = "Частный IP-адрес виртуальной машины"
}

output "instance_name" {
  value       = yandex_compute_instance.vm.name
  description = "Имя виртуальной машины"
}

output "disk_id" {
  value       = yandex_compute_instance.vm.boot_disk[0].disk_id
  description = "Идентификатор загрузочного диска"
}
