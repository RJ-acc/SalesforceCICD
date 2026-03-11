@isTest
public class BatchAccountCleanupTest {
    @isTest static void testBatch() {
        insert new List<Account>{ new Account(Name = '  Test  '), new Account(Name = 'Clean') };
        Test.startTest();
        Database.executeBatch(new BatchAccountCleanup(), 200);
        Test.stopTest();
        System.assert([SELECT COUNT() FROM Account] > 0);
    }
}