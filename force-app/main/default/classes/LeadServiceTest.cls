@isTest
public class LeadServiceTest {
    @TestSetup static void setupData() {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 10; i++) leads.add(new Lead(FirstName = 'Test', LastName = 'Lead ' + i, Company = 'Co ' + i, Email = 'test' + i + '@example.com', Status = Math.mod(i, 2) == 0 ? 'Open - Not Contacted' : 'Working - Contacted'));
        insert leads;
    }
    @isTest static void testGetAll() { System.assert(LeadService.getLeads('All').size() > 0); }
    @isTest static void testGetByStatus() { System.assert(LeadService.getLeads('Open - Not Contacted').size() > 0); }
    @isTest static void testCreate() { System.assertNotEquals(null, LeadService.createLead('John', 'Doe', 'Acme', 'j@acme.com', '555', 'Open - Not Contacted').Id); }
    @isTest static void testStatusMap() { System.assert(LeadService.getLeadsByStatus().size() > 0); }
}