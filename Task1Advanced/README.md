# Task1Advanced

Terraform-конфигурация создаёт виртуальную машину в Yandex Cloud с отдельным загрузочным диском.
Общий модуль находится в `modules/vm` и используется тремя независимыми окружениями: `dev`, `stage` и `prod`.

## Что делает модуль

Модуль `modules/vm`:

- получает образ Ubuntu из семейства `ubuntu-2604-lts`;
- создаёт загрузочный диск заданного типа и размера;
- создаёт виртуальную машину с заданным количеством ядер и объёмом памяти;
- подключает виртуальную машину к указанной подсети;
- добавляет публичный SSH-ключ для пользователя `testUser`.

## Входные параметры

| Параметр    | Тип      | Обязательный | Описание                                         |
|-------------|----------|--------------|--------------------------------------------------|
| `cpu`       | `number` | да           | Количество ядер процессора                       |
| `mem`       | `number` | да           | Объём оперативной памяти в ГБ                    |
| `subnet_id` | `string` | да           | Идентификатор подсети Yandex Cloud               |
| `ssh_pub`   | `string` | да           | Содержимое публичного SSH-ключа                  |
| `zone`      | `string` | да           | Зона размещения виртуальной машины и диска       |
| `disk_size` | `number` | да           | Размер диска в ГБ                                |
| `disk_type` | `string` | нет          | Тип диска; значение по умолчанию — `network-ssd` |
| `disk_name` | `string` | да           | Имя загрузочного диска                           |
| `vm_name`   | `string` | да           | Имя виртуальной машины                           |

Значения параметров каждого окружения находятся в файлах `envs/<окружение>/<окружение>.tfvars`.

## Выходные значения

| Выход           | Описание                                   |
|-----------------|--------------------------------------------|
| `instance_id`   | Идентификатор созданной виртуальной машины |
| `instance_ip`   | Частный IP-адрес виртуальной машины        |
| `instance_name` | Имя виртуальной машины                     |
| `disk_id`       | Идентификатор загрузочного диска           |

## Проверка форматирования

Все команды ниже выполняются из каталога `Task1Advanced`:

```shell
terraform fmt -check -recursive .
```

Для автоматического исправления форматирования:

```shell
terraform fmt -recursive .
```

## Запуск окружений

### Dev

```shell
terraform -chdir=envs/dev init
terraform -chdir=envs/dev validate
terraform -chdir=envs/dev plan -var-file=dev.tfvars
terraform -chdir=envs/dev apply -var-file=dev.tfvars
```

### Stage

```shell
terraform -chdir=envs/stage init
terraform -chdir=envs/stage validate
terraform -chdir=envs/stage plan -var-file=stage.tfvars
terraform -chdir=envs/stage apply -var-file=stage.tfvars
```

### Prod

```shell
terraform -chdir=envs/prod init
terraform -chdir=envs/prod validate
terraform -chdir=envs/prod plan -var-file=prod.tfvars
terraform -chdir=envs/prod apply -var-file=prod.tfvars
```

Для выполнения `plan` и `apply` необходимо заменить учебные значения `subnet_id` и `ssh_pub` в соответствующем
`.tfvars`-файле на реальные значения, а также настроить авторизацию в Yandex Cloud.

В рамках учебного задания команды `plan` и `apply` не выполнялись из-за отсутствия доступа к инфраструктуре
Yandex Cloud. Корректность структуры и синтаксиса проверяется командами `terraform fmt -check` и
`terraform validate`.
