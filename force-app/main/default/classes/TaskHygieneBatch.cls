public with sharing class TaskHygieneBatch implements Database.Batchable<SObject>, Database.Stateful {
    private final Integer olderThanDays;
    @TestVisible private Integer closedCount = 0;

    public TaskHygieneBatch(Integer olderThanDays) {
        this.olderThanDays = (olderThanDays == null || olderThanDays < 1) ? 30 : olderThanDays;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date cutoffDate = Date.today().addDays(-olderThanDays);
        return Database.getQueryLocator([
            SELECT Id, Status, IsClosed, ActivityDate
            FROM Task
            WHERE IsClosed = false
                AND ActivityDate < :cutoffDate
        ]);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Task> toClose = new List<Task>();
        for (SObject item : scope) {
            Task taskRecord = (Task)item;
            taskRecord.Status = 'Completed';
            toClose.add(taskRecord);
        }

        if (!toClose.isEmpty()) {
            update toClose;
            closedCount += toClose.size();
        }
    }

    public void finish(Database.BatchableContext bc) {
    }

    @AuraEnabled
    public static Id runNow(Integer olderThanDays, Integer scopeSize) {
        Integer safeScope = (scopeSize == null || scopeSize < 1) ? 100 : Math.min(scopeSize, 2000);
        return Database.executeBatch(new TaskHygieneBatch(olderThanDays), safeScope);
    }
}
