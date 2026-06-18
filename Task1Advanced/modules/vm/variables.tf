variable "cpu" {
  type = number
  description = "Количество ядер процессора"
}

variable "mem" {
  type = number
  description = "Объём оперативной памяти (Gb)"
}

variable "subnet_id" {
  type = string
  description = "Идентификатор подсети"
}

variable "ssh_pub_path" {
  type = string
  description = "Путь к файлу с открытым SSH ключом"
}

variable "zone" {
  type = string
  description = "Зона размещения ВМ и диска"
}

variable "disk_block_size" {
  type = number
  description = "Размер блока диска в байтах"
}

variable "disk_type" {
  type = string
  description = "Тип диска"
  default = "network-ssd"
}
