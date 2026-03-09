@isTest
public class OpportunityServiceTest {
    @TestSetup static void setupData() {
        Account acc = new Account(Name = 'Test Account'); insert acc;
        List<Opportunity> opps = new List<Opportunity>();
        String[] stages = new String[]{'Prospecting', 'Qualification', 'Closed Won'};
        for (Integer i = 0; i < 9; i++) opps.add(new Opportunity(Name = 'Opp ' + i, AccountId = acc.Id, Amount = 10000 + (i * 5000), CloseDate = Date.today().addDays(i * 10), StageName = stages[Math.mod(i, 3)]));
        insert opps;
    }
    @isTest static void testGetAll() { System.assert(OpportunityService.getOpportunities('All').size() > 0); }
    @isTest static void testGetByStage() { for (Opportunity o : OpportunityService.getOpportunities('Prospecting')) System.assertEquals('Prospecting', o.StageName); }
    @isTest static void testCreate() { Account a = [SELECT Id FROM Account LIMIT 1]; System.assertNotEquals(null, OpportunityService.createOpportunity('Deal', a.Id, 50000, Date.today().addDays(30), 'Prospecting').Id); }
    @isTest static void testUpdateStage() { Opportunity o = [SELECT Id FROM Opportunity WHERE StageName = 'Prospecting' LIMIT 1]; System.assertEquals('Qualification', OpportunityService.updateStage(o.Id, 'Qualification').StageName); }
    @isTest static void testPipeline() { System.assert(OpportunityService.getPipelineSummary().size() > 0); }
    @isTest static void testClosingSoon() { System.assertNotEquals(null, OpportunityService.getClosingSoon(90)); }
}