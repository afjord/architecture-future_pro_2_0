variable "cpu" {
  type        = number
  description = "Количество ядер процессора"
}

variable "mem" {
  type        = number
  description = "Объём оперативной памяти в ГБ"
}

variable "subnet_id" {
  type        = string
  description = "Идентификатор подсети"
}

variable "ssh_pub" {
  type        = string
  description = "Публичный SSH-ключ"
  sensitive   = true
}

variable "zone" {
  type        = string
  description = "Зона размещения виртуальной машины и диска"
}

variable "disk_size" {
  type        = number
  description = "Размер диска в ГБ"
}

variable "disk_name" {
  type        = string
  description = "Имя диска"
}

variable "vm_name" {
  type        = string
  description = "Имя виртуальной машины"
}
