public with sharing class ReportGenerator {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getSalesDashboardData() {
        Map<String, Object> d = new Map<String, Object>();
        d.put('totalAccounts', [SELECT COUNT() FROM Account]);
        d.put('totalContacts', [SELECT COUNT() FROM Contact]);
        d.put('totalOpportunities', [SELECT COUNT() FROM Opportunity WHERE IsClosed = false]);
        d.put('openCases', [SELECT COUNT() FROM Case WHERE IsClosed = false]);
        List<AggregateResult> pv = [SELECT SUM(Amount) total FROM Opportunity WHERE IsClosed = false];
        Decimal tp = (Decimal) pv[0].get('total'); d.put('pipelineValue', tp != null ? tp : 0);
        List<AggregateResult> wv = [SELECT SUM(Amount) total FROM Opportunity WHERE StageName = 'Closed Won'];
        Decimal tw = (Decimal) wv[0].get('total'); d.put('closedWonValue', tw != null ? tw : 0);
        return d;
    }
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getTopAccounts(Integer topN) {
        List<Map<String, Object>> top = new List<Map<String, Object>>();
        for (AggregateResult ar : [SELECT AccountId, Account.Name accName, SUM(Amount) total FROM Opportunity WHERE StageName = 'Closed Won' GROUP BY AccountId, Account.Name ORDER BY SUM(Amount) DESC LIMIT :topN]) {
            Map<String, Object> row = new Map<String, Object>(); row.put('accountName', ar.get('accName')); row.put('totalRevenue', ar.get('total')); top.add(row);
        }
        return top;
    }
}