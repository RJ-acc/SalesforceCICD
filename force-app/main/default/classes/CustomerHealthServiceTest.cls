@isTest
public class CustomerHealthServiceTest {
    @isTest static void testGetAccountHealth() {
        Account accountRecord = AppTestDataFactory.createAccounts(1, true)[0];
        AppTestDataFactory.createOpenCases(accountRecord.Id, 2, true);
        AppTestDataFactory.createOpenOpportunities(accountRecord.Id, 3, true);
        AppTestDataFactory.createOpenTasks(UserInfo.getUserId(), accountRecord.Id, 1, true);

        CustomerHealthService.AccountHealthSummary summary = CustomerHealthService.getAccountHealth(accountRecord.Id);

        System.assertEquals(accountRecord.Id, summary.accountId);
        System.assertEquals(2, summary.openCaseCount);
        System.assertEquals(3, summary.openOpportunityCount);
        System.assertEquals(1, summary.dueTaskCount);
        System.assert(summary.healthScore >= 0);
        System.assert(summary.healthScore <= 100);
    }

    @isTest static void testGetPortfolioHealth() {
        List<Account> accounts = AppTestDataFactory.createAccounts(2, true);
        AppTestDataFactory.createOpenCases(accounts[0].Id, 1, true);
        AppTestDataFactory.createOpenOpportunities(accounts[1].Id, 1, true);

        List<CustomerHealthService.AccountHealthSummary> summaries =
            CustomerHealthService.getPortfolioHealth(new List<Id>{ accounts[0].Id, accounts[1].Id });

        System.assertEquals(2, summaries.size());
    }

    @isTest static void testGetPortfolioHealthWithEmptyInput() {
        List<CustomerHealthService.AccountHealthSummary> summaries = CustomerHealthService.getPortfolioHealth(new List<Id>());
        System.assertEquals(0, summaries.size());
    }
}
