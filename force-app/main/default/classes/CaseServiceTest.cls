@isTest
public class CaseServiceTest {
    @TestSetup static void setupData() {
        Account acc = new Account(Name = 'Test'); insert acc;
        Contact con = new Contact(FirstName = 'T', LastName = 'C', AccountId = acc.Id); insert con;
        List<Case> cases = new List<Case>();
        String[] p = new String[]{'Low', 'Medium', 'High'}; String[] s = new String[]{'New', 'Working', 'Escalated'};
        for (Integer i = 0; i < 9; i++) cases.add(new Case(Subject = 'Case ' + i, Priority = p[Math.mod(i, 3)], Status = s[Math.mod(i, 3)], ContactId = con.Id, AccountId = acc.Id));
        insert cases;
    }
    @isTest static void testGetAll() { System.assert(CaseService.getCases('All', 'All').size() > 0); }
    @isTest static void testGetByStatus() { System.assert(CaseService.getCases('New', 'All').size() > 0); }
    @isTest static void testCreate() { Account a = [SELECT Id FROM Account LIMIT 1]; Contact c = [SELECT Id FROM Contact LIMIT 1]; System.assertNotEquals(null, CaseService.createCase('Issue', 'Desc', 'High', c.Id, a.Id).Id); }
    @isTest static void testUpdate() { Case c = [SELECT Id FROM Case LIMIT 1]; System.assertEquals('Working', CaseService.updateCaseStatus(c.Id, 'Working').Status); }
    @isTest static void testEscalate() { Case c = [SELECT Id FROM Case WHERE Priority != 'High' LIMIT 1]; System.assertEquals('High', CaseService.escalateCase(c.Id).Priority); }
    @isTest static void testMetrics() { System.assertNotEquals(null, CaseService.getCaseMetrics().get('totalOpen')); }
}