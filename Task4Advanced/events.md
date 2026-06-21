# Каталог доменных событий

## Общий контракт

События именуются в прошедшем времени: это неизменяемые факты, а не просьбы выполнить действие. Публичный
envelope одинаков по структуре, но payload принадлежит контексту-источнику.

```json
{
  "eventId": "uuid",
  "eventType": "PatientRegistered",
  "eventVersion": 1,
  "occurredAt": "2026-06-21T09:00:00Z",
  "producer": "patient-management",
  "aggregateId": "pat_01...",
  "aggregateVersion": 3,
  "correlationId": "uuid",
  "causationId": "uuid",
  "region": "RU-MSK",
  "classification": "restricted",
  "payload": {}
}
```

Обязательные поля payload перечислены ниже. Имена технических полей едины, но общей «корпоративной бизнес-
модели» нет. Новые необязательные поля добавляются backward-compatible; удаление, смена типа или семантики
требуют новой major-версии и периода параллельной публикации.

## Публичные интеграционные события

| Событие                          | Контекст-источник      | Семантика                                                  | Минимальный payload                                                                             | Классификация                           |
|----------------------------------|------------------------|------------------------------------------------------------|-------------------------------------------------------------------------------------------------|-----------------------------------------|
| `PatientRegistered.v1`           | Управление пациентами  | Регистрация пациента завершена, публичный ID назначен      | `patientId`, `homeRegion`, `registeredAt`                                                       | Restricted; без ФИО и контактов         |
| `PatientConsentChanged.v1`       | Управление пациентами  | Вступила в силу новая версия согласия или отзыва           | `patientId`, `consentType`, `status`, `effectiveAt`, `consentVersion`                           | Restricted                              |
| `AppointmentScheduled.v1`        | Расписание и приём     | Слот подтверждён за пациентом                              | `appointmentId`, `patientId`, `clinicId`, `serviceCode`, `startsAt`                             | Restricted                              |
| `AppointmentCancelled.v1`        | Расписание и приём     | Подтверждённая запись отменена                             | `appointmentId`, `cancelledAt`, `reasonCode`, `initiatorType`                                   | Internal                                |
| `VisitStarted.v1`                | Расписание и приём     | Пациентский визит фактически начат                         | `appointmentId`, `visitId`, `clinicId`, `startedAt`                                             | Restricted                              |
| `VisitCompleted.v1`              | Расписание и приём     | Оказание услуг в рамках визита завершено                   | `visitId`, `patientId`, `clinicId`, `serviceCodes`, `completedAt`                               | Restricted; без клинического содержания |
| `InvoiceIssued.v1`               | Биллинг                | Счёт стал обязательством к оплате                          | `invoiceId`, `accountId`, `amount`, `currency`, `dueAt`, `sourceRef`                            | Confidential                            |
| `InvoiceSettled.v1`              | Биллинг                | Остаток по счёту стал равен нулю                           | `invoiceId`, `settledAt`, `settlementRefs`                                                      | Confidential                            |
| `PaymentReceived.v1`             | Платежи                | Денежные средства успешно приняты и проводка зафиксирована | `paymentId`, `accountId`, `amount`, `currency`, `receivedAt`, `allocationRef`                   | Confidential                            |
| `PaymentFailed.v1`               | Платежи                | Платёжная попытка завершилась без списания                 | `paymentId`, `failedAt`, `reasonCode`, `retryable`                                              | Confidential; без реквизитов карты      |
| `PaymentRefunded.v1`             | Платежи                | Возврат средств зафиксирован                               | `paymentId`, `refundId`, `amount`, `currency`, `refundedAt`                                     | Confidential                            |
| `CreditApplicationSubmitted.v1`  | Кредитование           | Заявка принята в рассмотрение                              | `applicationId`, `customerId`, `productCode`, `requestedAmount`, `currency`, `submittedAt`      | Confidential                            |
| `CreditDecisionMade.v1`          | Кредитование           | Зафиксировано окончательное решение по заявке              | `applicationId`, `decision`, `decisionAt`, `decisionPolicyVersion`, `reasonCodes`, `validUntil` | Highly confidential                     |
| `LoanAgreementCreated.v1`        | Кредитование           | Кредитный договор заключён и получил номер                 | `loanAgreementId`, `customerId`, `productCode`, `principal`, `currency`, `signedAt`             | Highly confidential                     |
| `LoanScheduleCreated.v1`         | Кредитование           | Утверждена версия графика платежей                         | `loanAgreementId`, `scheduleVersion`, `firstDueAt`, `maturityAt`, `installmentCount`            | Confidential                            |
| `LoanPaymentBooked.v1`           | Кредитование           | Платёж распределён на кредитное обязательство              | `loanAgreementId`, `paymentId`, `principalAmount`, `interestAmount`, `bookedAt`                 | Highly confidential                     |
| `LoanPaymentOverdue.v1`          | Кредитование           | Обязательный платёж не получен к контрольному сроку        | `loanAgreementId`, `installmentId`, `overdueSince`, `overdueAmount`, `currency`                 | Highly confidential                     |
| `EmployeeHired.v1`               | Персонал               | Начался трудовой период сотрудника                         | `employeeId`, `organizationUnitId`, `roleCodes`, `effectiveAt`                                  | Restricted; без персональных атрибутов  |
| `EmployeeTerminated.v1`          | Персонал               | Трудовой период завершён                                   | `employeeId`, `organizationUnitId`, `effectiveAt`                                               | Restricted                              |
| `ResourceAvailabilityChanged.v1` | Ресурсы и инвентарь    | Изменилась возможность использовать ресурс в расписании    | `resourceId`, `resourceType`, `locationId`, `availability`, `effectiveAt`                       | Internal                                |
| `ModelVersionReleased.v1`        | Жизненный цикл моделей | Версия модели разрешена для заданной области применения    | `modelVersionId`, `modelType`, `intendedUse`, `releasedAt`, `artifactChecksum`                  | Internal                                |
| `ModelVersionWithdrawn.v1`       | Жизненный цикл моделей | Версия запрещена для новых запусков                        | `modelVersionId`, `withdrawnAt`, `reasonCode`                                                   | Internal                                |

## События защищённого клинического контура

Эти события передаются только по отдельным защищённым topics и не реплицируются в DWH/Lakehouse. Доступ имеют
минимально необходимые медицинские и ИИ-сервисы. В публичный аналитический контур privacy filter выпускает
отдельные обезличенные метрики, а не копии этих сообщений.

| Событие                          | Контекст-источник    | Семантика                                                             | Минимальный payload                                                                |
|----------------------------------|----------------------|-----------------------------------------------------------------------|------------------------------------------------------------------------------------|
| `ClinicalEncounterOpened.v1`     | Клиническая практика | Для визита открыт эпизод медицинской помощи                           | `encounterId`, `patientId`, `visitId`, `practitionerId`, `openedAt`                |
| `DiagnosticStudyOrdered.v1`      | Клиническая практика | Врач подписал назначение на исследование                              | `orderId`, `encounterId`, `patientId`, `studyType`, `priority`, `orderedAt`        |
| `DiagnosticStudyCompleted.v1`    | Диагностика          | Результат исследования подписан и доступен                            | `studyId`, `orderId`, `patientId`, `resultRef`, `completedAt`, `contentChecksum`   |
| `AIStudyAnalyzed.v1`             | Оркестрация ИИ       | Модель завершила анализ; это не клинический диагноз                   | `analysisId`, `studyId`, `modelVersionId`, `resultRef`, `confidence`, `analyzedAt` |
| `ClinicalConclusionConfirmed.v1` | Клиническая практика | Врач подписал клиническое заключение, рассмотрев доступные результаты | `encounterId`, `conclusionId`, `practitionerId`, `confirmedAt`, `sourceRefs`       |

`resultRef` — короткоживущая либо policy-controlled ссылка/идентификатор объекта внутри защищённого контура;
результат, снимок и текст заключения в сообщение не включаются.

## Доставка и эксплуатационные гарантии

- Публикация — `at least once` через transactional outbox; потребитель обязан быть идемпотентным.
- Порядок гарантируется только внутри одного aggregate/partition key, обычно `aggregateId`.
- Событие считается доступным потребителям только после проверки Schema Registry; несовместимые сообщения идут
  в карантин/DLQ и не маскируются автоматическим преобразованием.
- Retention, шифрование и разрешённые регионы задаются по `classification`; payload не содержит секретов,
  платёжных реквизитов, изображений или диагностических текстов.
- У каждого события есть owner, SLO доставки, список зарегистрированных потребителей и процедура replay.
- Replay не выполняет повторную бизнес-операцию: inbox и `eventId` предотвращают дубли, а side effects используют
  собственный `idempotencyKey`.

