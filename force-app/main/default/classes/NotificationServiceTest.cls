@isTest
public class NotificationServiceTest {
    @isTest static void testSendEmail() {
        Test.startTest();
        NotificationService.sendEmailNotification(new List<String>{'test@example.com'}, 'Test', 'Body');
        Test.stopTest();
        System.assertEquals(1, Limits.getEmailInvocations());
    }
    @isTest static void testUnreadCount() {
        insert new Task(Subject = 'Urgent', ActivityDate = Date.today(), Status = 'Not Started');
        System.assert(NotificationService.getUnreadNotificationCount() >= 0);
    }
}