output "instance_id" {
  value       = module.vm.instance_id
  description = "Id ВМ"
}

output "instance_ip" {
  value       = module.vm.instance_ip
  description = "Частный IP адрес"
}

output "instance_name" {
  value       = module.vm.instance_name
  description = "Название ВМ"
}

output "disk_id" {
  value       = module.vm.disk_id
  description = "Id диска"
}
