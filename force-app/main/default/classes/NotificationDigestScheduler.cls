public with sharing class NotificationDigestScheduler implements Schedulable {
    private static final String DIGEST_SUBJECT = 'Daily Task Digest';

    public void execute(SchedulableContext sc) {
        sendCurrentUserDigest();
    }

    @AuraEnabled
    public static Integer sendCurrentUserDigest() {
        return sendDigestForUser(UserInfo.getUserId(), UserInfo.getUserEmail());
    }

    @TestVisible
    private static Integer sendDigestForUser(Id userId, String userEmail) {
        if (String.isBlank(userEmail)) {
            return 0;
        }

        Integer openDueTaskCount = [
            SELECT COUNT()
            FROM Task
            WHERE OwnerId = :userId
                AND IsClosed = false
                AND ActivityDate <= TODAY
            WITH USER_MODE
        ];

        if (openDueTaskCount == 0) {
            return 0;
        }

        String body = 'You have ' + String.valueOf(openDueTaskCount) + ' open task(s) due today or earlier.';
        NotificationService.sendEmailNotification(new List<String>{ userEmail }, DIGEST_SUBJECT, body);
        return openDueTaskCount;
    }
}
