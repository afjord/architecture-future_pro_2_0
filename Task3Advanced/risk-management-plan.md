# План управления рисками

## Принципы

- Для каждого риска назначается один accountable owner; комитет не заменяет владельца.
- Технические контроли автоматизируются и проверяются тестом, метрикой или аудитом.
- Управленческие меры закрепляют финансирование, ответственность, порядок принятия решений и обучение.
- Критические миграции выполняются через pilot, dual run, reconciliation, cutover и проверенный rollback.
- Остаточный риск принимается владельцем бизнеса и CISO/комплаенсом, если он связан с регулируемыми данными.

## Меры по рискам

В колонке «Целевой остаточный риск» значения указаны в формате `вероятность / влияние` после выполнения мер.

| ID   | Конкретные меры снижения                                                                                                                                  | Тип мер                        | Владелец                            | Срок / этап                       | Целевой остаточный риск |
|------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------|-------------------------------------|-----------------------------------|-------------------------|
| A-01 | Физически отделить clinical store; allow-list событий Privacy Filter; DLP и schema checks в CI; запретить ingestion снимков/карт; quarterly access review | Технические + управленческие   | CISO и Medical Data Owner           | До первого пилота, постоянно      | Низкая / высокое        |
| A-02 | Доменные события вместо enterprise canonical model; schema ownership; compatibility checks; consumer-driven contract tests; deprecation policy            | Технические + управленческие   | Chief Architect и Domain Architects | 0–6 месяцев                       | Средняя / среднее       |
| A-03 | Учредить Metrics Council; вести версионированный glossary; реализовать Semantic Layer; автоматизировать reconciliation с утверждёнными отчётами           | Технические + управленческие   | CDO и Finance Data Owner            | Пилот, затем каждый домен         | Средняя / среднее       |
| A-04 | Event storming и context mapping; Architecture Decision Records; запрет shared database; анализ runtime dependencies и fitness functions                  | Технические + управленческие   | Chief Architect                     | До onboarding домена              | Низкая / среднее        |
| A-05 | Зафиксировать freeze date; реестр потребителей; anti-corruption adapters только с owner и expiry date; exit criteria и бюджет decommission                | Преимущественно управленческие | Transformation Director             | Все этапы, закрытие 18–36 месяцев | Средняя / среднее       |
| A-06 | Региональные deployment cells; data residency labels; policy-as-code на маршрутизацию; отдельные KMS keys; legal assessment передачи данных               | Технические + управленческие   | CISO и Regional Compliance          | До выхода в каждый регион         | Низкая / высокое        |
| A-07 | Workload groups, quota, timeout, result cache, async exports, pre-aggregations; FinOps budgets и showback по доменам                                      | Преимущественно технические    | Data Platform Owner и FinOps        | Portal MVP, постоянно             | Средняя / среднее       |
| O-01 | Назначить Data Owner/Steward; включить SLA, quality score и документацию в Definition of Done; chargeback/showback и lifecycle policy                     | Преимущественно управленческие | CDO и Domain Directors              | 0–6 месяцев                       | Средняя / среднее       |
| O-02 | Skills matrix; обучение и pairing; platform paved road; runbooks/game days; план снижения bus factor; выборочный внешний найм                             | Преимущественно управленческие | CTO и Engineering Managers          | 0–18 месяцев                      | Средняя / среднее       |
| O-03 | Совместное проектирование Portal; пилот с power users; обучение; измерение adoption; ограниченный parallel run; дата прекращения legacy UI                | Управленческие                 | Product Owner Portal                | 0–18 месяцев                      | Средняя / низкое        |
| O-04 | Security/privacy-by-design; CISO и legal в product teams; threat modeling и DPIA до разработки; автоматические compliance evidence                        | Технические + управленческие   | CISO и Legal                        | С 0-го месяца                     | Низкая / среднее        |
| O-05 | Ограничить WIP; stage gates 0–6/6–18/18–36; финансировать capability, а не разовые интеграции; квартальные outcome/kill reviews                           | Управленческие                 | Steering Committee                  | Ежеквартально                     | Средняя / среднее       |
| T-01 | Нагрузочный тест CDC на replica; throttling и backpressure; initial snapshot вне пика; outbox для новых сервисов; count/checksum reconciliation           | Преимущественно технические    | Legacy Migration Lead               | 0–18 месяцев                      | Средняя / среднее       |
| T-02 | Data contracts; profiling; quality rules у источника и при публикации; quarantine; scorecards; root-cause SLA домена                                      | Технические + управленческие   | Domain Data Owners                  | С пилота, постоянно               | Средняя / среднее       |
| T-03 | Multi-AZ; capacity reserve; backup/restore; cross-region strategy по классу данных; chaos/game days; подтверждённые RPO/RTO                               | Преимущественно технические    | Platform SRE Lead                   | До production, раз в полгода      | Низкая / высокое        |
| T-04 | Idempotency key и inbox/outbox; deduplication; partition ordering; dry-run replay; four-eyes approval для финансового replay                              | Технические + управленческие   | Event Platform Owner                | 0–6 месяцев                       | Низкая / среднее        |
| T-05 | Central IdP, MFA, least privilege, RBAC + ABAC, SoD; policy tests; JIT access; quarterly recertification; audit bulk exports                              | Технические + управленческие   | IAM Owner и CISO                    | До Portal MVP, постоянно          | Низкая / высокое        |
| T-06 | Open event/table formats; abstraction at boundaries; portability test; tagged unit economics; budgets/alerts; contract exit clauses                       | Технические + управленческие   | CTO Procurement и FinOps            | При выборе платформы, ежегодно    | Средняя / низкое        |

## Контроль выполнения

| Периодичность           | Контроль                                                                  | Условие эскалации                                               |
|-------------------------|---------------------------------------------------------------------------|-----------------------------------------------------------------|
| На каждый merge/release | Schema compatibility, policy tests, IaC/security scan, data quality tests | Любой breaking contract или запрещённое поле блокирует релиз    |
| Еженедельно             | Consumer lag, DLQ age, quality score, access anomalies, cloud unit cost   | Нарушение SLO два периода подряд                                |
| Ежемесячно              | Критические/высокие риски, владельцы и срок мер                           | Нет owner, просрочена мера или риск вырос                       |
| Ежеквартально           | Adoption Portal, legacy consumers, KPI reconciliation, права доступа      | Не снижается legacy footprint или KPI расходятся                |
| Раз в полгода           | DR/restore, replay game day, incident simulation                          | RPO/RTO не подтверждены — расширение доменов приостанавливается |

## Управленческие решения, которые нельзя заменить технологией

Технология не определит корректные доменные границы, владельцев показателей, допустимую цель использования данных
или момент отключения legacy. Для этого нужны решения руководителей доменов, CDO, CISO и владельцев бизнеса.
Аналогично, автоматический контроль не заменяет финансирование обучения, приоритизацию миграции, принятие
остаточного риска и ответственность за качество data product.

## Технические решения, которые должны быть автоматизированы

Schema compatibility, DLP, quality gates, policy-as-code, lineage, audit, idempotency, quota, backup/restore и
наблюдаемость нельзя оставлять только в виде регламентов. Их проверка должна входить в CI/CD, runtime policy
enforcement и регулярные recovery/replay tests с сохраняемыми доказательствами выполнения.
