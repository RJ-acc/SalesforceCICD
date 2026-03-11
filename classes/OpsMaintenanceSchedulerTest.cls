@isTest
public class OpsMaintenanceSchedulerTest {
    @isTest static void testScheduleDaily() {
        Test.startTest();
        String jobId = OpsMaintenanceScheduler.scheduleDaily('OpsMaintTestJob', 3, 15);
        Test.stopTest();

        CronTrigger cronRow = [SELECT Id, CronExpression FROM CronTrigger WHERE Id = :jobId LIMIT 1];
        System.assertNotEquals(null, cronRow);
        System.assert(cronRow.CronExpression.contains('15 3'));
    }

    @isTest static void testExecuteRunsBatch() {
        Account accountRecord = AppTestDataFactory.createAccounts(1, true)[0];
        List<Task> tasks = AppTestDataFactory.createOpenTasks(UserInfo.getUserId(), accountRecord.Id, 1, true);
        tasks[0].ActivityDate = Date.today().addDays(-45);
        update tasks;

        Test.startTest();
        new OpsMaintenanceScheduler().execute(null);
        Test.stopTest();

        Task refreshed = [SELECT Id, Status FROM Task WHERE Id = :tasks[0].Id LIMIT 1];
        System.assertEquals('Completed', refreshed.Status);
    }
}