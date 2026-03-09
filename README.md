# Salesforce CICD Sample (Production-Style Additions)

This repository now includes a production-style notification module and scheduler that you can deploy and test in any org.

## Added Use Cases

- `NotificationService`
  - Validates email payloads
  - Normalizes and deduplicates recipient addresses
  - Splits large recipient lists into chunks of 100 per email
  - Supports single-request and bulk-request email sends
  - Exposes an `@AuraEnabled` method for UI-triggered sends
- `NotificationDigestScheduler`
  - Schedulable Apex job for daily task-digest notifications
  - Sends a digest email only when open tasks are due today or earlier

## Apex Classes Added/Updated

- `force-app/main/default/classes/NotificationService.cls`
- `force-app/main/default/classes/NotificationServiceTest.cls`
- `force-app/main/default/classes/NotificationDigestScheduler.cls`
- `force-app/main/default/classes/NotificationDigestSchedulerTest.cls`

## Deploy and Test

### Validate deployment

```bash
sf project deploy start --source-dir force-app --dry-run --wait 20
```

### Deploy with local tests

```bash
sf project deploy start --source-dir force-app --test-level RunLocalTests --wait 30
```

### Run only notification-related tests

```bash
sf apex run test --tests NotificationServiceTest,NotificationDigestSchedulerTest --result-format human --wait 20
```

## Notes

- Jenkins quality gates for ESLint/RetireJS are expected to pass with current changes.
- PMD warnings may still exist in legacy sample classes and can be addressed separately if you want stricter gates.
