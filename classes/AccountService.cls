public with sharing class AccountService {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(Integer limitCount) {
        return [SELECT Id, Name, Industry, AnnualRevenue, Phone, Website, BillingCity, BillingState, NumberOfEmployees, Rating FROM Account WITH USER_MODE ORDER BY Name LIMIT :limitCount];
    }
    @AuraEnabled
    public static Account createAccount(String name, String industry, String phone, String website) {
        Account acc = new Account(Name = name, Industry = industry, Phone = phone, Website = website);
        Database.insert(acc, AccessLevel.USER_MODE);
        return acc;
    }
    @AuraEnabled
    public static Account updateAccount(Id accountId, String name, String industry, Decimal revenue) {
        Account acc = [SELECT Id FROM Account WHERE Id = :accountId WITH USER_MODE LIMIT 1];
        acc.Name = name; acc.Industry = industry; acc.AnnualRevenue = revenue;
        Database.update(acc, AccessLevel.USER_MODE);
        return acc;
    }
    @AuraEnabled
    public static void deleteAccount(Id accountId) {
        Account acc = [SELECT Id FROM Account WHERE Id = :accountId WITH USER_MODE LIMIT 1];
        Database.delete(acc, AccessLevel.USER_MODE);
    }
    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccounts(String searchKey) {
        String key = '%' + searchKey + '%';
        return [SELECT Id, Name, Industry, Phone FROM Account WHERE Name LIKE :key WITH USER_MODE LIMIT 20];
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getAccountsByIndustry() {
        Map<String, Integer> industryMap = new Map<String, Integer>();
        for (AggregateResult ar : [SELECT Industry, COUNT(Id) cnt FROM Account WITH USER_MODE GROUP BY Industry]) {
            String industry = (String) ar.get('Industry');
            if (industry != null) industryMap.put(industry, (Integer) ar.get('cnt'));
        }
        return industryMap;
    }
}