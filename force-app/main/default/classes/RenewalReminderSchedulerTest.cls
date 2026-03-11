@isTest
public class RenewalReminderSchedulerTest {
    @isTest static void testSendDigestToCurrentUserWhenRenewalsExist() {
        Account accountRecord = AppTestDataFactory.createAccounts(1, true)[0];
        List<Opportunity> opportunities = AppTestDataFactory.createOpenOpportunities(accountRecord.Id, 2, true);
        opportunities[0].CloseDate = Date.today().addDays(3);
        opportunities[1].CloseDate = Date.today().addDays(6);
        update opportunities;

        Test.startTest();
        Integer remindersSent = RenewalReminderScheduler.sendDigestToCurrentUser(10);
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(2, remindersSent);
        System.assertEquals(1, emailInvocations);
    }

    @isTest static void testSendDigestToCurrentUserWhenNoRenewals() {
        Test.startTest();
        Integer remindersSent = RenewalReminderScheduler.sendDigestToCurrentUser(5);
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(0, remindersSent);
        System.assertEquals(0, emailInvocations);
    }

    @isTest static void testBuildDigestBody() {
        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(Name = 'Opp-A', CloseDate = Date.today().addDays(1), Amount = 1234.56),
            new Opportunity(Name = 'Opp-B', CloseDate = Date.today().addDays(2), Amount = null)
        };

        String body = RenewalReminderScheduler.buildDigestBody(opportunities, 7);
        System.assert(body.contains('Upcoming renewals'));
        System.assert(body.contains('Opp-A'));
        System.assert(body.contains('Opp-B'));
    }
}
