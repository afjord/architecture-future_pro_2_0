# Task2Advanced: Terraform, GitLab CI и удалённое состояние

Проект создаёт виртуальную машину с отдельным загрузочным диском в Yandex Cloud. Один Terraform-модуль`modules/vm`
используется независимыми окружениями `dev`, `stage` и `prod`.

Состояние каждого окружения хранится в Yandex Object Storage через S3 backend. GitLab CI проверяет код, формирует план и
позволяет применить только ранее сформированный план вручную.

## Структура

```text
Task2Advanced/
├── envs/
│   ├── dev/
│   ├── stage/
│   └── prod/
└── modules/
    └── vm/
```

Каждый каталог в `envs` является отдельным корневым Terraform-модулем и содержит собственные параметры, S3 backend и
lock-файл провайдера. Pipeline описан в файле `.gitlab-ci.yml` в каталоге этого задания.

Поскольку проект учебный, то CI-файл находится не в корне репозитория.

## Что создаёт модуль

Модуль `modules/vm`:

- находит образ семейства `ubuntu-2604-lts`;
- создаёт загрузочный сетевой SSD-диск;
- создаёт виртуальную машину;
- подключает её к заданной подсети;
- записывает публичный SSH-ключ пользователя `testUser` в metadata.

## Параметры Terraform

| Параметр    | Тип      | Источник в CI      | Описание                   |
|-------------|----------|--------------------|----------------------------|
| `cpu`       | `number` | `.tfvars`          | Количество ядер процессора |
| `mem`       | `number` | `.tfvars`          | Объём памяти в ГБ          |
| `zone`      | `string` | `.tfvars`          | Зона размещения ресурсов   |
| `disk_size` | `number` | `.tfvars`          | Размер диска в ГБ          |
| `disk_name` | `string` | `.tfvars`          | Имя диска                  |
| `vm_name`   | `string` | `.tfvars`          | Имя виртуальной машины     |
| `subnet_id` | `string` | `TF_VAR_subnet_id` | Идентификатор подсети      |
| `ssh_pub`   | `string` | `TF_VAR_ssh_pub`   | Публичный SSH-ключ         |

Параметры, зависящие от инфраструктуры, не записываются в репозиторий. GitLab передаёт их через переменные окружения
Terraform с префиксом `TF_VAR_`.

## Выходные значения

| Выход           | Описание                            |
|-----------------|-------------------------------------|
| `instance_id`   | Идентификатор виртуальной машины    |
| `instance_ip`   | Частный IP-адрес виртуальной машины |
| `instance_name` | Имя виртуальной машины              |
| `disk_id`       | Идентификатор загрузочного диска    |

## Удалённое состояние

Файл `backend.tf` настраивает S3 backend с endpoint `https://storage.yandexcloud.net`. Имя bucket и ключ состояния
передаются во время `terraform init`, потому что backend не поддерживает обычные Terraform variables.

Pipeline использует один bucket и разные ключи:

| Окружение | Ключ объекта состояния          |
|-----------|---------------------------------|
| `dev`     | `task2/dev/terraform.tfstate`   |
| `stage`   | `task2/stage/terraform.tfstate` |
| `prod`    | `task2/prod/terraform.tfstate`  |

Такая схема исключает совместное использование state разными окружениями. Параметр `use_lockfile = true` включает
блокировку состояния объектом `.tflock`, чтобы два pipeline не изменяли одно состояние одновременно. Дополнительно
GitLab `resource_group` последовательно выполняет jobs одного окружения.

Локальные файлы `*.tfstate`, каталоги `.terraform` и сохранённые планы исключены через `.gitignore`. Lock-файлы
`.terraform.lock.hcl` коммитятся и фиксируют проверенную версию провайдера.

Перед первым запуском необходимо создать приватный bucket Yandex Object Storage. Публичный доступ к bucket и объектам
состояния должен быть запрещён, а шифрование на стороне хранилища — включено.

## Переменные GitLab CI/CD

Переменные создаются в `Settings → CI/CD → Variables`. Секретные значения необходимо пометить как `Masked` и
`Protected`. Для `TF_VAR_subnet_id` и `TF_VAR_ssh_pub` рекомендуется задать environment scope отдельно для `dev`,
`stage` и `prod`.

| Переменная              | Назначение                                           | Рекомендуемые флаги |
|-------------------------|------------------------------------------------------|---------------------|
| `TF_STATE_BUCKET`       | Имя приватного bucket для state                      | Protected           |
| `AWS_ACCESS_KEY_ID`     | Static access key сервисного аккаунта для S3 backend | Masked, Protected   |
| `AWS_SECRET_ACCESS_KEY` | Secret key сервисного аккаунта для S3 backend        | Masked, Protected   |
| `YC_TOKEN`              | Токен авторизации Yandex provider                    | Masked, Protected   |
| `YC_CLOUD_ID`           | Идентификатор облака                                 | Protected           |
| `YC_FOLDER_ID`          | Идентификатор каталога                               | Protected           |
| `TF_VAR_subnet_id`      | Подсеть конкретного окружения                        | Environment scoped  |
| `TF_VAR_ssh_pub`        | Публичный SSH-ключ                                   | Environment scoped  |

Сервисному аккаунту следует выдать только права, необходимые для управления заданными ресурсами и объектами state. Для
production следует использовать protected branch, protected environment и обязательное подтверждение ответственным
пользователем. Краткоживущий `YC_TOKEN` предпочтительнее постоянного токена.

## Логика pipeline

Pipeline состоит из трёх стадий.

### `validate`

Запускается для merge request и default branch:

1. `terraform fmt -check -recursive Task2Advanced` проверяет форматирование.
2. `terraform init -backend=false -lockfile=readonly` инициализирует каждый root module без доступа к state.
3. `terraform validate` проверяет все три конфигурации.

Merge request не получает доступ к удалённому state и protected credentials.

### `plan`

Jobs `plan_dev`, `plan_stage`, `plan_prod` запускаются только в default branch. Каждая job:

1. подключает S3 backend с отдельным state key;
2. выполняет `terraform plan` с параметрами своего окружения;
3. сохраняет бинарный `tfplan` и текстовое представление на один час.

Доступ к artifacts ограничен ролью Developer. План потенциально может содержать чувствительные значения,
поэтому его нельзя публиковать или хранить длительное время.

### `apply`

Jobs `apply_dev`, `apply_stage`, `apply_prod` запускаются только вручную (`when: manual`) в default branch. Каждая job
получает artifact соответствующего plan job и применяет именно сохранённый `tfplan`, не формируя новый план. Terraform
отклонит устаревший план, если удалённое состояние успело измениться.

## Локальная проверка

Все команды выполняются из каталога `Task2Advanced`.

Проверка форматирования:

```shell
terraform fmt -check -recursive .
```

Проверка конфигураций без подключения к удалённому state:

```shell
terraform -chdir=envs/dev init -backend=false
terraform -chdir=envs/dev validate

terraform -chdir=envs/stage init -backend=false
terraform -chdir=envs/stage validate

terraform -chdir=envs/prod init -backend=false
terraform -chdir=envs/prod validate
```

## Ручной запуск с backend

Для примера `dev` сначала необходимо передать credentials и параметры инфраструктуры через environment variables:

```shell
export TF_STATE_BUCKET="replace-with-private-bucket"
export AWS_ACCESS_KEY_ID="replace-with-static-access-key"
export AWS_SECRET_ACCESS_KEY="replace-with-secret-key"
export YC_TOKEN="replace-with-yandex-token"
export YC_CLOUD_ID="replace-with-cloud-id"
export YC_FOLDER_ID="replace-with-folder-id"
export TF_VAR_subnet_id="replace-with-subnet-id"
export TF_VAR_ssh_pub="replace-with-public-ssh-key"
```

Инициализация, plan и apply:

```shell
terraform -chdir=envs/dev init -reconfigure \
  -backend-config="bucket=${TF_STATE_BUCKET}" \
  -backend-config="key=task2/dev/terraform.tfstate"

terraform -chdir=envs/dev plan -var-file=dev.tfvars -out=tfplan
terraform -chdir=envs/dev apply tfplan
```

Для `stage` и `prod` используются их каталоги, `.tfvars` и state key. Реальные `plan` и `apply` в рамках учебного
задания не выполнялись, поскольку доступ к Yandex Cloud и S3 bucket отсутствует.
