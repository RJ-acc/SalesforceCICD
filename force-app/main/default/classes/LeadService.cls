public with sharing class LeadService {
    @AuraEnabled(cacheable=true)
    public static List<Lead> getLeads(String status) {
        if (String.isBlank(status) || status == 'All') return [SELECT Id, FirstName, LastName, Company, Email, Phone, Status, LeadSource, Rating FROM Lead ORDER BY CreatedDate DESC LIMIT 50];
        return [SELECT Id, FirstName, LastName, Company, Email, Phone, Status, LeadSource, Rating FROM Lead WHERE Status = :status ORDER BY CreatedDate DESC LIMIT 50];
    }
    @AuraEnabled
    public static Lead createLead(String firstName, String lastName, String company, String email, String phone, String status) {
        Lead l = new Lead(FirstName = firstName, LastName = lastName, Company = company, Email = email, Phone = phone, Status = status);
        insert l; return l;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getLeadsByStatus() {
        Map<String, Integer> statusMap = new Map<String, Integer>();
        for (AggregateResult ar : [SELECT Status, COUNT(Id) cnt FROM Lead GROUP BY Status]) statusMap.put((String) ar.get('Status'), (Integer) ar.get('cnt'));
        return statusMap;
    }
}