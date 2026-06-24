output "instance_id" {
  value       = module.vm.instance_id
  description = "Идентификатор виртуальной машины"
}

output "instance_ip" {
  value       = module.vm.instance_ip
  description = "Частный IP-адрес виртуальной машины"
}

output "instance_name" {
  value       = module.vm.instance_name
  description = "Имя виртуальной машины"
}

output "disk_id" {
  value       = module.vm.disk_id
  description = "Идентификатор загрузочного диска"
}
