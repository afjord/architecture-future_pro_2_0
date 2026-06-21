# Расширенный технологический радар

## Правила радара

Радар фиксирует решение на начало трёхлетней трансформации. Статус относится к использованию в новых решениях,
а не к факту наличия технологии в компании.

| Статус     | Правило применения                                                                         |
|------------|--------------------------------------------------------------------------------------------|
| **Adopt**  | Стандарт для production; платформенная команда предоставляет шаблон, поддержку и контроль  |
| **Trial**  | Ограниченный production-пилот с владельцем, метриками успеха и датой пересмотра            |
| **Assess** | Исследование/PoC без критичных production-нагрузок и долгосрочных обязательств             |
| **Hold**   | Не применять в новых решениях; существующее использование только поддерживать или выводить |

## Архитектура и способы работы

| Подход или паттерн                                       | Статус    | Обоснование и область применения                                                                        | Следующее решение / критерий перехода                                                  |
|----------------------------------------------------------|-----------|---------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------|
| Domain-Driven Design, bounded contexts                   | **Adopt** | Даёт медицинскому, ИИ-, финтех- и корпоративному доменам собственные модели и границы изменений         | Architecture review проверяет владение данными и отсутствие shared database            |
| Event-Driven Architecture                                | **Adopt** | Основной способ распространения состоявшихся междоменных фактов и near-real-time реакций                | Для каждого события обязательны owner, схема, SLO, classification и consumers          |
| Transactional Outbox + Inbox/Idempotent Consumer         | **Adopt** | Устраняет dual write и делает `at least once` безопасным                                                | Шаблоны для Java/Python, тест дубля и replay в release pipeline                        |
| Data Contracts и schema evolution                        | **Adopt** | Контракт фиксирует семантику, качество, совместимость и владельца data product/event                    | Breaking change только новой major-версией с dual publication                          |
| Data Mesh                                                | **Trial** | Нужна доменная ответственность за data products, но организационная модель ещё не доказана              | Перевести в Adopt после двух доменов с owner, SLO, quality score и активными consumers |
| Data Product thinking                                    | **Adopt** | Набор публикуется как продукт: discoverable, addressable, trustworthy, secure и interoperable           | Product scorecard и квартальный review владельца                                       |
| Self-service BI и управляемый Data Portal                | **Trial** | Снижает очередь к центральной BI-команде, но требует guardrails по доступу и стоимости                  | ≥60% типовых запросов без заявки; 0 критичных утечек; p95 в пределах SLO               |
| Federated Computational Governance                       | **Trial** | Общие политики исполняются платформой, семантика и качество принадлежат доменам                         | Policy-as-code для classification, locality, retention и compatibility                 |
| API-first: REST/GraphQL, gRPC внутри доверенного контура | **Adopt** | Синхронные запросы остаются для немедленного ответа; GraphQL используется BFF, gRPC — сервис-сервис     | Не использовать синхронную цепочку для распространения бизнес-фактов                   |
| Privacy by design, data minimization                     | **Adopt** | Клинические данные физически отделены; аналитика получает только разрешённые минимизированные данные    | DLP/privacy tests блокируют публикацию до Lakehouse                                    |
| Event Sourcing «по умолчанию»                            | **Hold**  | Event backbone не заменяет доменное хранилище; сложность восстановления не оправдана для всех агрегатов | Допустим только отдельный ADR с доказанной потребностью в полной истории состояния     |
| Shared database между доменами                           | **Hold**  | Создаёт скрытую связанность и распределённое владение схемой                                            | Интеграция только через опубликованный API/событие/data product                        |

## Платформа данных и интеграций

| Технология                                    | Статус     | Назначение и решение                                                                                                   | Следующее решение / критерий перехода                                                    |
|-----------------------------------------------|------------|------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------|
| Apache Kafka                                  | **Trial**  | Основной кандидат для Event Backbone, DLQ и consumer groups; выбран единый кандидат вместо одновременного Kafka/Pulsar | Пилот: multi-AZ, replay, ACL, p95 доставки ≤5 с, RPO/RTO и нагрузочный тест              |
| Apache Pulsar                                 | **Assess** | Альтернатива Kafka для geo-replication и tenant isolation                                                              | Сравнивать только если Kafka не проходит региональные или экономические критерии         |
| Schema Registry + Apache Avro                 | **Trial**  | Реестр версий событий и компактный основной формат междоменных контрактов                                              | Compatibility checks во всех CI/CD pipelines; аварийный rollback схемы                   |
| Protobuf / JSON Schema                        | **Assess** | Protobuf возможен для gRPC, JSON Schema — для внешних партнёров; не вводить три формата без необходимости              | Утвердить format decision matrix и ownership tooling                                     |
| Debezium CDC                                  | **Trial**  | Временный мост от SQL Server/Camel и legacy-источников к backbone                                                      | Lag, полнота и нагрузка на source; вывести вместе с последним legacy-потоком             |
| Apache Flink                                  | **Trial**  | Основной кандидат для stateful stream processing и near-real-time представлений                                        | Exactly-once state, checkpoint/restore, p95 lag и стоимость на пилотах                   |
| Spark Structured Streaming                    | **Assess** | Альтернатива Flink при переиспользовании Spark-компетенций                                                             | Не эксплуатировать параллельно без подтверждённого workload gap                          |
| Apache Airflow + dbt                          | **Adopt**  | Оркестрация batch, исторических расчётов, тестируемых SQL-трансформаций и сверок                                       | Общие шаблоны DAG, lineage и data tests                                                  |
| S3-compatible Object Storage + Apache Iceberg | **Trial**  | Lakehouse с открытым форматом, разделением доменов/регионов и независимыми compute/storage                             | Проверить schema evolution, time travel, compaction, encryption и Trino interoperability |
| Trino                                         | **Trial**  | Распределённый SQL query engine для Lakehouse и Portal                                                                 | Workload groups, row/column policies, p95 и unit cost запроса                            |
| Cube semantic layer                           | **Trial**  | Единые определения KPI, метрик и измерений без возврата логики в DWH                                                   | Сверка 10 приоритетных KPI с регламентной отчётностью                                    |
| OpenMetadata                                  | **Trial**  | Каталог, ownership, classification, quality score и lineage data products                                              | ≥95% production-продуктов имеют owner, описание, SLA и lineage                           |
| Great Expectations                            | **Trial**  | Контрактные проверки полноты, корректности и свежести данных                                                           | Quality gates встроены в batch/stream publishing pipeline                                |
| PostgreSQL                                    | **Adopt**  | Транзакционное хранилище метаданных и версий Report Designer                                                           | Managed HA/backup, encryption и проверенный restore                                      |
| Microsoft SQL Server 2008 DWH                 | **Hold**   | Только read-only история, сверка и архив до завершения миграции                                                        | Запрет новых ETL/витрин; отключение после exit criteria                                  |
| Apache Camel как центральная ESB              | **Hold**   | Только anti-corruption adapters на период миграции                                                                     | Запрет новых бизнес-маршрутов; удаление после последнего consumer                        |

## Приложения, ML, безопасность и эксплуатация

| Технология                                 | Статус     | Назначение и решение                                                                             | Следующее решение / критерий перехода                                                |
|--------------------------------------------|------------|--------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------|
| Java 21 + Spring Boot                      | **Adopt**  | Основной стек доменных сервисов, Portal API/BFF, adapters и process managers                     | Golden path: security, outbox, telemetry, contract tests и SBOM                      |
| React + TypeScript                         | **Adopt**  | SPA Self-Service Data Portal и новые доменные интерфейсы                                         | Общая design system, OIDC client и frontend observability                            |
| Python + стандартизованный model serving   | **Adopt**  | Обучение и inference медицинских моделей в защищённом контуре                                    | Версионирование модели, provenance, human-in-the-loop и rollback                     |
| PowerBuilder                               | **Hold**   | Legacy UI поддерживается только до переноса функций                                              | Нет новых экранов; usage telemetry и поэтапный cutover                               |
| OIDC, OAuth 2.0, MFA                       | **Adopt**  | Единая аутентификация пользователей и workload identity                                          | Короткоживущие токены, rotation и phishing-resistant MFA для привилегированных ролей |
| RBAC + ABAC / policy-as-code               | **Trial**  | Контекстные решения по домену, цели, классификации, согласию и региону                           | Default deny, decision audit и негативные security tests                             |
| Microsoft Presidio + Vault/KMS             | **Trial**  | Обнаружение PII, маскирование, токенизация и управление ключами Privacy Filter                   | Recall на контрольном наборе, ротация ключей и запрет re-identification              |
| OpenTelemetry                              | **Adopt**  | Единая трассировка API, событий, batch и пользовательских запросов                               | `correlationId` проходит от Portal/producer до consumer и аудита                     |
| SIEM                                       | **Adopt**  | Неизменяемый аудит доступа, выгрузок и security-событий                                          | Retention, алерты bulk export и регулярная проверка расследования                    |
| Terraform / Infrastructure as Code         | **Adopt**  | Воспроизводимые окружения и policy checks, согласовано с заданиями 1–2                           | Plan review, state isolation, drift detection и запрет ручных production-изменений   |
| S3 signed URL + TTL для выгрузок           | **Adopt**  | Временная доставка зашифрованных экспортов без проксирования больших файлов через Portal         | Короткий TTL, одноразовый доступ, audit и lifecycle deletion                         |
| Активный multi-region для всех компонентов | **Assess** | Требует доказанного RTO и экономического обоснования; не все workloads нуждаются в active-active | Выбирать по BIA домена, требованиям локализации и DR-тестам                          |

## Управление радаром

Architecture Council пересматривает радар ежеквартально. Для `Trial` назначаются owner, срок не более двух
кварталов, бюджет и измеримые exit criteria. Технология не переходит в `Adopt` только потому, что пилот запущен:
нужны эксплуатационные доказательства, компетенции минимум двух команд, security review, TCO и проверенный
recovery. Новая технология с дублирующей функцией требует ADR и плана вывода проигравшего решения.

