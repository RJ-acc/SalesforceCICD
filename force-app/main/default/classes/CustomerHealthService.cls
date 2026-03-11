public with sharing class CustomerHealthService {
    public class AccountHealthSummary {
        @AuraEnabled public Id accountId;
        @AuraEnabled public String accountName;
        @AuraEnabled public Integer openCaseCount;
        @AuraEnabled public Integer openOpportunityCount;
        @AuraEnabled public Integer dueTaskCount;
        @AuraEnabled public Decimal openPipelineAmount;
        @AuraEnabled public Integer healthScore;
        @AuraEnabled public String healthBand;
    }

    @AuraEnabled(cacheable=true)
    public static AccountHealthSummary getAccountHealth(Id accountId) {
        if (accountId == null) {
            throw new AuraHandledException('Account Id is required.');
        }

        Account accountRecord = [
            SELECT Id, Name
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];

        Integer openCaseCount = [
            SELECT COUNT()
            FROM Case
            WHERE AccountId = :accountId
                AND IsClosed = false
        ];

        List<AggregateResult> openOpportunityStats = [
            SELECT COUNT(Id) totalCount, SUM(Amount) totalAmount
            FROM Opportunity
            WHERE AccountId = :accountId
                AND IsClosed = false
        ];

        Integer openOpportunityCount = 0;
        Decimal openPipelineAmount = 0;
        if (!openOpportunityStats.isEmpty()) {
            Object totalCountValue = openOpportunityStats[0].get('totalCount');
            Object totalAmountValue = openOpportunityStats[0].get('totalAmount');
            openOpportunityCount = (totalCountValue == null) ? 0 : Integer.valueOf(String.valueOf(totalCountValue));
            openPipelineAmount = (totalAmountValue == null) ? 0 : Decimal.valueOf(String.valueOf(totalAmountValue));
        }

        Integer dueTaskCount = [
            SELECT COUNT()
            FROM Task
            WHERE WhatId = :accountId
                AND IsClosed = false
                AND ActivityDate <= :Date.today()
        ];

        Integer healthScore = calculateHealthScore(openCaseCount, openOpportunityCount, dueTaskCount, openPipelineAmount);

        AccountHealthSummary summary = new AccountHealthSummary();
        summary.accountId = accountRecord.Id;
        summary.accountName = accountRecord.Name;
        summary.openCaseCount = openCaseCount;
        summary.openOpportunityCount = openOpportunityCount;
        summary.dueTaskCount = dueTaskCount;
        summary.openPipelineAmount = openPipelineAmount;
        summary.healthScore = healthScore;
        summary.healthBand = classifyHealthBand(healthScore);
        return summary;
    }

    @AuraEnabled(cacheable=true)
    public static List<AccountHealthSummary> getPortfolioHealth(List<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return new List<AccountHealthSummary>();
        }

        List<AccountHealthSummary> output = new List<AccountHealthSummary>();
        for (Id accountId : accountIds) {
            output.add(getAccountHealth(accountId));
        }
        return output;
    }

    private static Integer calculateHealthScore(
        Integer openCaseCount,
        Integer openOpportunityCount,
        Integer dueTaskCount,
        Decimal openPipelineAmount
    ) {
        Integer score = 100;
        score -= openCaseCount * 8;
        score -= dueTaskCount * 5;
        score += openOpportunityCount * 4;
        if (openPipelineAmount > 50000) {
            score += 5;
        }

        if (score < 0) {
            score = 0;
        }
        if (score > 100) {
            score = 100;
        }
        return score;
    }

    private static String classifyHealthBand(Integer healthScore) {
        if (healthScore >= 80) {
            return 'GREEN';
        }
        if (healthScore >= 50) {
            return 'YELLOW';
        }
        return 'RED';
    }
}
