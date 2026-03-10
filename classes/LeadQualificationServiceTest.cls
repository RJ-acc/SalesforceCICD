@isTest
public class LeadQualificationServiceTest {
    @isTest static void testQualifyLeads() {
        List<Lead> leads = AppTestDataFactory.createLeads(2, true);
        leads[0].Phone = '1234567890';
        leads[0].Title = 'VP Sales';
        leads[0].AnnualRevenue = 2500000;
        leads[0].NumberOfEmployees = 300;
        update leads;

        Test.startTest();
        List<LeadQualificationService.LeadQualificationResult> results =
            LeadQualificationService.qualifyLeads(new List<Id>{ leads[0].Id, leads[1].Id });
        Test.stopTest();

        System.assertEquals(2, results.size());

        Lead refreshedLead = [SELECT Id, Rating, Description FROM Lead WHERE Id = :leads[0].Id LIMIT 1];
        System.assertNotEquals(null, refreshedLead.Rating);
        System.assert(refreshedLead.Description.contains('Qualification score'));
    }

    @isTest static void testQualifyLeadsWithEmptyInput() {
        List<LeadQualificationService.LeadQualificationResult> results = LeadQualificationService.qualifyLeads(new List<Id>());
        System.assertEquals(0, results.size());
    }

    @isTest static void testScoreLead() {
        Lead leadRecord = new Lead(
            LastName = 'Score Test',
            Company = 'Score Company',
            Email = 'score@example.com',
            Phone = '1112223333',
            Title = 'Director',
            AnnualRevenue = 1500000,
            NumberOfEmployees = 120
        );
        Integer score = LeadQualificationService.scoreLead(leadRecord);
        System.assert(score >= 70);
    }
}