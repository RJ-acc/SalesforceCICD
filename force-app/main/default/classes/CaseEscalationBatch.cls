public with sharing class CaseEscalationBatch implements Database.Batchable<SObject>, Database.Stateful {
    private final Integer caseAgeDays;
    @TestVisible private Integer escalatedCount = 0;

    public CaseEscalationBatch(Integer caseAgeDays) {
        this.caseAgeDays = (caseAgeDays == null || caseAgeDays < 0) ? 3 : caseAgeDays;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime cutoffDate = System.now().addDays(-caseAgeDays);
        return Database.getQueryLocator([
            SELECT Id, Priority, Status, CreatedDate
            FROM Case
            WHERE IsClosed = false
                AND CreatedDate <= :cutoffDate
        ]);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Case> toUpdate = new List<Case>();
        for (SObject item : scope) {
            Case caseRecord = (Case)item;
            if (caseRecord.Priority != 'High') {
                caseRecord.Priority = 'High';
                toUpdate.add(caseRecord);
            }
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
            escalatedCount += toUpdate.size();
        }
    }

    public void finish(Database.BatchableContext bc) {
    }

    @AuraEnabled
    public static Id runNow(Integer caseAgeDays, Integer batchScope) {
        Integer scope = (batchScope == null || batchScope < 1) ? 100 : batchScope;
        return Database.executeBatch(new CaseEscalationBatch(caseAgeDays), scope);
    }
}
