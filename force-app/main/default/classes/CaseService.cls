public with sharing class CaseService {
    @AuraEnabled(cacheable=true)
    public static List<Case> getCases(String status, String priority) {
        String q = 'SELECT Id, CaseNumber, Subject, Status, Priority, Description, CreatedDate, Contact.Name, Account.Name FROM Case';
        List<String> conds = new List<String>();
        if (String.isNotBlank(status) && status != 'All') conds.add('Status = :status');
        if (String.isNotBlank(priority) && priority != 'All') conds.add('Priority = :priority');
        if (!conds.isEmpty()) q += ' WHERE ' + String.join(conds, ' AND ');
        q += ' WITH USER_MODE ORDER BY CreatedDate DESC LIMIT 50';
        return Database.query(q);
    }
    @AuraEnabled
    public static Case createCase(String subject, String description, String priority, Id contactId, Id accountId) {
        Case c = new Case(Subject = subject, Description = description, Priority = priority, ContactId = contactId, AccountId = accountId, Status = 'New', Origin = 'Web');
        Database.insert(c, AccessLevel.USER_MODE); return c;
    }
    @AuraEnabled
    public static Case updateCaseStatus(Id caseId, String newStatus) {
        Case c = [SELECT Id FROM Case WHERE Id = :caseId WITH USER_MODE LIMIT 1]; c.Status = newStatus; Database.update(c, AccessLevel.USER_MODE); return c;
    }
    @AuraEnabled
    public static Case escalateCase(Id caseId) {
        Case c = [SELECT Id FROM Case WHERE Id = :caseId WITH USER_MODE LIMIT 1]; c.Priority = 'High'; c.Status = 'Escalated'; Database.update(c, AccessLevel.USER_MODE); return c;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCaseMetrics() {
        Map<String, Object> m = new Map<String, Object>();
        m.put('totalOpen', [SELECT COUNT() FROM Case WHERE IsClosed = false WITH USER_MODE]);
        m.put('totalClosed', [SELECT COUNT() FROM Case WHERE IsClosed = true WITH USER_MODE]);
        m.put('highPriority', [SELECT COUNT() FROM Case WHERE Priority = 'High' AND IsClosed = false WITH USER_MODE]);
        return m;
    }
}
