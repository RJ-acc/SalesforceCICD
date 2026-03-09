@isTest
public class NotificationDigestSchedulerTest {
    @isTest static void testSendDigestReturnsZeroWhenNoOpenDueTasks() {
        Test.startTest();
        Integer openTasksSent = NotificationDigestScheduler.sendDigestForUser(UserInfo.getUserId(), 'digest@example.com');
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(0, openTasksSent);
        System.assertEquals(0, emailInvocations);
    }

    @isTest static void testSendDigestSendsEmailForOpenDueTasks() {
        insert new List<Task>{
            new Task(
                Subject = 'Open Due Today',
                ActivityDate = Date.today(),
                Status = 'Not Started',
                Priority = 'Normal',
                OwnerId = UserInfo.getUserId()
            ),
            new Task(
                Subject = 'Closed Task',
                ActivityDate = Date.today(),
                Status = 'Completed',
                Priority = 'Normal',
                OwnerId = UserInfo.getUserId()
            )
        };

        Test.startTest();
        Integer openTasksSent = NotificationDigestScheduler.sendDigestForUser(UserInfo.getUserId(), 'digest@example.com');
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(1, openTasksSent);
        System.assertEquals(1, emailInvocations);
    }

    @isTest static void testSchedulableJobCanBeScheduled() {
        Test.startTest();
        String jobId = System.schedule('NotificationDigestSchedulerJob', '0 0 6 * * ?', new NotificationDigestScheduler());
        Test.stopTest();

        CronTrigger trigger = [SELECT Id FROM CronTrigger WHERE Id = :jobId LIMIT 1];
        System.assertNotEquals(null, trigger);
    }
}
