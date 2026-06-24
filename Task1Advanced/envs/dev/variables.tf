variable "cpu" {
  type        = number
  description = "Количество ядер процессора"
}

variable "mem" {
  type        = number
  description = "Объём оперативной памяти (Gb)"
}

variable "subnet_id" {
  type        = string
  description = "Идентификатор подсети"
}

variable "ssh_pub" {
  type        = string
  description = "Открытый ключ ssh"
}

variable "zone" {
  type        = string
  description = "Зона размещения ВМ и диска"
}

variable "disk_size" {
  type        = number
  description = "Размер диска в (Gb)"
}

variable "disk_name" {
  type        = string
  description = "Название диска"
}

variable "vm_name" {
  type        = string
  description = "Название ВМ"
}
