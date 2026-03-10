// Run with: sf apex run --file scripts/apex/opsHealthCheck.apex
Map<String, Object> snapshot = SalesMetricsController.getWeeklySnapshot();
System.debug('Weekly snapshot: ' + JSON.serializePretty(snapshot));

Integer digestCount = NotificationDigestScheduler.sendCurrentUserDigest();
System.debug('Digest items processed: ' + digestCount);
