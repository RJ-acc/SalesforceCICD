@isTest
public class ReportGeneratorTest {
    @TestSetup static void setupData() {
        Account acc = new Account(Name = 'Test'); insert acc;
        insert new Contact(FirstName = 'T', LastName = 'C', AccountId = acc.Id);
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) opps.add(new Opportunity(Name = 'Deal ' + i, AccountId = acc.Id, Amount = 10000 + (i * 5000), CloseDate = Date.today().addDays(-i * 30), StageName = i < 3 ? 'Closed Won' : 'Prospecting'));
        insert opps;
    }
    @isTest static void testDashboard() { Map<String, Object> d = ReportGenerator.getSalesDashboardData(); System.assertNotEquals(null, d.get('totalAccounts')); }
    @isTest static void testTopAccounts() { System.assertNotEquals(null, ReportGenerator.getTopAccounts(5)); }
}