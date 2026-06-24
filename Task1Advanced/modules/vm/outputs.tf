output "instance_id" {
  value       = yandex_compute_instance.testvm.id
  description = "Id ВМ"
}

output "instance_ip" {
  value       = yandex_compute_instance.testvm.network_interface[0].ip_address
  description = "Частный IP адрес"
}

output "instance_name" {
  value       = yandex_compute_instance.testvm.name
  description = "Название ВМ"
}

output "disk_id" {
  value       = yandex_compute_instance.testvm.boot_disk[0].disk_id
  description = "Id диска"
}
