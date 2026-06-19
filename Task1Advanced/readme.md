Запуск и проверка проекта:

Для запуска выполнить следующие команды:

Для dev кластера:

```shell
  terraform -chdir=envs/dev init
  terraform -chdir=envs/dev fmt -check
  terraform -chdir=envs/dev validate
```

Для stage кластера:

```shell
  terraform -chdir=envs/stage init
  terraform -chdir=envs/stage fmt -check
  terraform -chdir=envs/stage validate
```

Для prod кластера:

```shell
  terraform -chdir=envs/prod init
  terraform -chdir=envs/prod fmt -check
  terraform -chdir=envs/prod validate
```

Команды инициализируют окружение, проверяют форматирование файлов и валидируют конфигурацию.

После этого должны следовать команды plan и apply, но для этого необходимо заменить учебные значения `subnet_id` и
`ssh_pub` в `.tfvars` на реальные данные Yandex Cloud и настроить авторизацию провайдера.

Пример:

```shell
terraform -chdir=envs/dev plan -var-file=dev.tfvars
terraform -chdir=envs/dev apply -var-file=dev.tfvars
```

Команды plan/apply не выполнялись из-за отсутствия инфраструктуры и доступа к Yandex Cloud.
