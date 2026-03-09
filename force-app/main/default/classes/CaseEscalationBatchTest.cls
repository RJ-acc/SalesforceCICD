@isTest
public class CaseEscalationBatchTest {
    @isTest static void testRunNowEscalatesOldCases() {
        Account accountRecord = AppTestDataFactory.createAccounts(1, true)[0];
        List<Case> cases = AppTestDataFactory.createOpenCases(accountRecord.Id, 3, true);

        for (Case caseRecord : cases) {
            Test.setCreatedDate(caseRecord.Id, System.now().addDays(-10));
        }

        Test.startTest();
        Id jobId = CaseEscalationBatch.runNow(5, 50);
        Test.stopTest();

        System.assertNotEquals(null, jobId);

        Integer highPriorityCount = [
            SELECT COUNT()
            FROM Case
            WHERE Id IN :cases
                AND Priority = 'High'
        ];
        System.assertEquals(3, highPriorityCount);
    }

    @isTest static void testRunNowDoesNotEscalateNewCases() {
        Account accountRecord = AppTestDataFactory.createAccounts(1, true)[0];
        List<Case> cases = AppTestDataFactory.createOpenCases(accountRecord.Id, 2, true);

        Test.startTest();
        CaseEscalationBatch.runNow(5, 50);
        Test.stopTest();

        Integer mediumPriorityCount = [
            SELECT COUNT()
            FROM Case
            WHERE Id IN :cases
                AND Priority = 'Medium'
        ];
        System.assertEquals(2, mediumPriorityCount);
    }
}
