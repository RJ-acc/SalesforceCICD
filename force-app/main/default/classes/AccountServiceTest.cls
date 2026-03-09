@isTest
public class AccountServiceTest {
    @TestSetup
    static void setupData() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i, Industry = Math.mod(i, 2) == 0 ? 'Technology' : 'Finance', Phone = '123456789' + i, AnnualRevenue = 1000000 + (i * 50000)));
        }
        insert accounts;
    }
    @isTest static void testGetAccounts() { System.assert(AccountService.getAccounts(5).size() <= 5); }
    @isTest static void testCreateAccount() { System.assertNotEquals(null, AccountService.createAccount('New Corp', 'Technology', '5551234567', 'https://newcorp.com').Id); }
    @isTest static void testUpdateAccount() { Account a = [SELECT Id FROM Account LIMIT 1]; System.assertEquals('Updated', AccountService.updateAccount(a.Id, 'Updated', 'Healthcare', 5000000).Name); }
    @isTest static void testDeleteAccount() { Account a = [SELECT Id FROM Account LIMIT 1]; AccountService.deleteAccount(a.Id); System.assertEquals(0, [SELECT COUNT() FROM Account WHERE Id = :a.Id]); }
    @isTest static void testSearchAccounts() { System.assert(AccountService.searchAccounts('Test').size() > 0); }
    @isTest static void testGetAccountsByIndustry() { System.assert(AccountService.getAccountsByIndustry().size() > 0); }
}