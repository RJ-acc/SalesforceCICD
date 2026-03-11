public with sharing class OpportunityService {
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities(String stageName) {
        if (String.isBlank(stageName) || stageName == 'All') return [SELECT Id, Name, StageName, Amount, CloseDate, Probability, Account.Name FROM Opportunity ORDER BY CloseDate DESC LIMIT 50];
        return [SELECT Id, Name, StageName, Amount, CloseDate, Probability, Account.Name FROM Opportunity WHERE StageName = :stageName ORDER BY CloseDate DESC LIMIT 50];
    }
    @AuraEnabled
    public static Opportunity createOpportunity(String name, Id accountId, Decimal amount, Date closeDate, String stageName) {
        Opportunity opp = new Opportunity(Name = name, AccountId = accountId, Amount = amount, CloseDate = closeDate, StageName = stageName);
        insert opp; return opp;
    }
    @AuraEnabled
    public static Opportunity updateStage(Id oppId, String newStage) {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :oppId LIMIT 1];
        opp.StageName = newStage; update opp; return opp;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Decimal> getPipelineSummary() {
        Map<String, Decimal> summary = new Map<String, Decimal>();
        for (AggregateResult ar : [SELECT StageName, SUM(Amount) total FROM Opportunity GROUP BY StageName]) {
            Decimal total = (Decimal) ar.get('total');
            summary.put((String) ar.get('StageName'), total != null ? total : 0);
        }
        return summary;
    }
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getClosingSoon(Integer daysFromNow) {
        return [SELECT Id, Name, Amount, CloseDate, StageName, Account.Name FROM Opportunity WHERE CloseDate <= :Date.today().addDays(daysFromNow) AND IsClosed = false ORDER BY CloseDate ASC LIMIT 20];
    }
}