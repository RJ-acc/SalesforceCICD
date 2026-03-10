@isTest
public class TaskHygieneBatchTest {
    @isTest static void testRunNowClosesOldOpenTasks() {
        Account accountRecord = AppTestDataFactory.createAccounts(1, true)[0];
        List<Task> tasks = AppTestDataFactory.createOpenTasks(UserInfo.getUserId(), accountRecord.Id, 3, true);

        for (Task taskRecord : tasks) {
            taskRecord.ActivityDate = Date.today().addDays(-40);
        }
        update tasks;

        Test.startTest();
        Id jobId = TaskHygieneBatch.runNow(30, 50);
        Test.stopTest();

        System.assertNotEquals(null, jobId);

        Integer closedCount = [
            SELECT COUNT()
            FROM Task
            WHERE Id IN :tasks
                AND Status = 'Completed'
        ];
        System.assertEquals(3, closedCount);
    }

    @isTest static void testRunNowSkipsRecentTasks() {
        Account accountRecord = AppTestDataFactory.createAccounts(1, true)[0];
        List<Task> tasks = AppTestDataFactory.createOpenTasks(UserInfo.getUserId(), accountRecord.Id, 2, true);

        Test.startTest();
        TaskHygieneBatch.runNow(30, 50);
        Test.stopTest();

        Integer openCount = [
            SELECT COUNT()
            FROM Task
            WHERE Id IN :tasks
                AND Status = 'Not Started'
        ];
        System.assertEquals(2, openCount);
    }
}
