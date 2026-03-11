@isTest
public class SalesMetricsControllerTest {
    @isTest static void testGetWeeklySnapshot() {
        Account accountRecord = AppTestDataFactory.createAccounts(1, true)[0];
        AppTestDataFactory.createLeads(2, true);
        AppTestDataFactory.createOpenCases(accountRecord.Id, 1, true);
        AppTestDataFactory.createOpenTasks(UserInfo.getUserId(), accountRecord.Id, 1, true);
        AppTestDataFactory.createOpenOpportunities(accountRecord.Id, 2, true);

        Map<String, Object> snapshot = SalesMetricsController.getWeeklySnapshot();

        System.assert(snapshot.containsKey('newLeads'));
        System.assert(snapshot.containsKey('openOpportunities'));
        System.assert(snapshot.containsKey('openCases'));
        System.assert(snapshot.containsKey('tasksDueToday'));
        System.assert(snapshot.containsKey('openPipelineAmount'));
    }

    @isTest static void testGetTopOpenOpportunities() {
        Account accountRecord = AppTestDataFactory.createAccounts(1, true)[0];
        List<Opportunity> opportunities = AppTestDataFactory.createOpenOpportunities(accountRecord.Id, 3, true);
        opportunities[0].Amount = 25000;
        opportunities[1].Amount = 10000;
        opportunities[2].Amount = 5000;
        update opportunities;

        List<SalesMetricsController.OpportunitySnapshot> output = SalesMetricsController.getTopOpenOpportunities(2);
        System.assertEquals(2, output.size());
        System.assert(output[0].amount >= output[1].amount);
    }
}
