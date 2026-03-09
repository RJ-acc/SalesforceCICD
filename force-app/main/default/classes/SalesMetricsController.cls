public with sharing class SalesMetricsController {
    public class OpportunitySnapshot {
        @AuraEnabled public Id opportunityId;
        @AuraEnabled public String name;
        @AuraEnabled public String accountName;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public Date closeDate;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getWeeklySnapshot() {
        Map<String, Object> snapshot = new Map<String, Object>();
        Date lastWeek = Date.today().addDays(-7);

        snapshot.put('newLeads', [
            SELECT COUNT()
            FROM Lead
            WHERE CreatedDate >= :lastWeek
        ]);

        snapshot.put('openOpportunities', [
            SELECT COUNT()
            FROM Opportunity
            WHERE IsClosed = false
        ]);

        snapshot.put('openCases', [
            SELECT COUNT()
            FROM Case
            WHERE IsClosed = false
        ]);

        snapshot.put('tasksDueToday', [
            SELECT COUNT()
            FROM Task
            WHERE IsClosed = false
                AND ActivityDate = :Date.today()
        ]);

        List<AggregateResult> pipeline = [
            SELECT SUM(Amount) totalAmount
            FROM Opportunity
            WHERE IsClosed = false
        ];

        Decimal totalPipeline = 0;
        if (!pipeline.isEmpty() && pipeline[0].get('totalAmount') != null) {
            totalPipeline = Decimal.valueOf(String.valueOf(pipeline[0].get('totalAmount')));
        }
        snapshot.put('openPipelineAmount', totalPipeline);

        return snapshot;
    }

    @AuraEnabled(cacheable=true)
    public static List<OpportunitySnapshot> getTopOpenOpportunities(Integer limitSize) {
        Integer safeLimit = (limitSize == null || limitSize < 1) ? 10 : Math.min(limitSize, 100);
        List<OpportunitySnapshot> output = new List<OpportunitySnapshot>();

        List<Opportunity> opportunities = [
            SELECT Id, Name, Amount, CloseDate, Account.Name
            FROM Opportunity
            WHERE IsClosed = false
            ORDER BY Amount DESC NULLS LAST
            LIMIT :safeLimit
        ];

        for (Opportunity opp : opportunities) {
            OpportunitySnapshot item = new OpportunitySnapshot();
            item.opportunityId = opp.Id;
            item.name = opp.Name;
            item.accountName = (opp.Account == null) ? null : opp.Account.Name;
            item.amount = opp.Amount;
            item.closeDate = opp.CloseDate;
            output.add(item);
        }

        return output;
    }
}
