@isTest
public class NotificationServiceTest {
    @isTest static void testSendEmailSingleRequest() {
        Test.startTest();
        NotificationService.sendEmailNotification(new List<String>{'test@example.com'}, 'Test', 'Body');
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(1, emailInvocations);
    }

    @isTest static void testSendEmailFromUi() {
        Test.startTest();
        NotificationService.sendEmailNotificationFromUi('ui@example.com', 'UI Subject', 'UI Body');
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(1, emailInvocations);
    }

    @isTest static void testRejectsBlankSubject() {
        Boolean didThrow = false;

        try {
            NotificationService.sendEmailNotification(new List<String>{'test@example.com'}, '   ', 'Body');
        } catch (NotificationService.NotificationValidationException ex) {
            didThrow = true;
            System.assert(ex.getMessage().contains('subject'));
        }

        System.assert(didThrow, 'Expected a validation exception for blank subject.');
    }

    @isTest static void testRejectsInvalidRecipientList() {
        Boolean didThrow = false;

        try {
            NotificationService.sendEmailNotification(new List<String>{'   ', null}, 'Subject', 'Body');
        } catch (NotificationService.NotificationValidationException ex) {
            didThrow = true;
            System.assert(ex.getMessage().contains('recipient'));
        }

        System.assert(didThrow, 'Expected a validation exception for invalid recipients.');
    }

    @isTest static void testRecipientChunkingForBulkEmail() {
        List<String> recipients = new List<String>();
        for (Integer i = 0; i < 205; i++) {
            recipients.add('user' + String.valueOf(i) + '@example.com');
        }

        Integer chunkCount = NotificationService.getChunkCountForRecipients(recipients);
        System.assertEquals(3, chunkCount);
    }

    @isTest static void testUnreadCountFiltersByStatusAndDueDate() {
        insert new List<Task>{
            new Task(
                Subject = 'Due Today Open',
                ActivityDate = Date.today(),
                Status = 'Not Started',
                Priority = 'Normal',
                OwnerId = UserInfo.getUserId()
            ),
            new Task(
                Subject = 'Due Tomorrow Open',
                ActivityDate = Date.today().addDays(1),
                Status = 'Not Started',
                Priority = 'Normal',
                OwnerId = UserInfo.getUserId()
            ),
            new Task(
                Subject = 'Due Today Closed',
                ActivityDate = Date.today(),
                Status = 'Completed',
                Priority = 'Normal',
                OwnerId = UserInfo.getUserId()
            )
        };

        Integer unreadCount = NotificationService.getUnreadNotificationCount();
        System.assertEquals(1, unreadCount);
    }
}