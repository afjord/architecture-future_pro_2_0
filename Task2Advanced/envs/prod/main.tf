module "vm" {
  source = "../../modules/vm"

  cpu       = var.cpu
  disk_name = var.disk_name
  disk_size = var.disk_size
  mem       = var.mem
  ssh_pub   = var.ssh_pub
  subnet_id = var.subnet_id
  vm_name   = var.vm_name
  zone      = var.zone
}
