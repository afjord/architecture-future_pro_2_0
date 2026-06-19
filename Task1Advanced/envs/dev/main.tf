module "vm" {
  source = "../../modules/vm"

  cpu       = var.cpu
  disk_size = var.disk_size
  mem       = var.mem
  ssh_pub   = var.ssh_pub
  subnet_id = var.subnet_id
  zone      = var.zone
}
