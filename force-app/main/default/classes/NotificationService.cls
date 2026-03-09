public with sharing class NotificationService {
    public static void sendEmailNotification(List<String> toAddresses, String subject, String body) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toAddresses); email.setSubject(subject); email.setPlainTextBody(body); email.setSaveAsActivity(false);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
    }
    @AuraEnabled(cacheable=true)
    public static Integer getUnreadNotificationCount() {
        return [SELECT COUNT() FROM Task WHERE OwnerId = :UserInfo.getUserId() AND IsClosed = false AND ActivityDate <= TODAY];
    }
}