public class BatchAccountCleanup implements Database.Batchable<SObject>, Database.Stateful {
    private Integer processed = 0; private Integer updated = 0;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Name, Phone FROM Account WHERE LastModifiedDate < LAST_N_DAYS:365]);
    }
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        List<Account> toUpdate = new List<Account>();
        for (Account acc : scope) {
            processed++; Boolean needsUpdate = false;
            if (String.isNotBlank(acc.Name)) { String trimmed = acc.Name.trim(); if (trimmed != acc.Name) { acc.Name = trimmed; needsUpdate = true; } }
            if (needsUpdate) { toUpdate.add(acc); updated++; }
        }
        if (!toUpdate.isEmpty()) update toUpdate;
    }
    public void finish(Database.BatchableContext bc) { System.debug('Batch done. Processed: ' + processed + ', Updated: ' + updated); }
}