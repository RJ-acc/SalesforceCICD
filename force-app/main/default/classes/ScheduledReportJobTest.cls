@isTest
public class ScheduledReportJobTest {
    @isTest static void testSchedule() {
        Test.startTest();
        String jobId = System.schedule('Test Report', '0 0 6 * * ?', new ScheduledReportJob());
        Test.stopTest();
        System.assertEquals('0 0 6 * * ?', [SELECT CronExpression FROM CronTrigger WHERE Id = :jobId].CronExpression);
    }
}