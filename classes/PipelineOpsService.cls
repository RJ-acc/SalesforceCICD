public with sharing class PipelineOpsService {
    public class OwnerWorkload {
        @AuraEnabled public Id ownerId;
        @AuraEnabled public Integer openTaskCount;
        @AuraEnabled public Integer overdueTaskCount;
        @AuraEnabled public Integer openCaseCount;
        @AuraEnabled public Integer openOpportunityCount;
        @AuraEnabled public Decimal openPipelineAmount;
    }

    public class ReassignResult {
        @AuraEnabled public Integer movedCount;
        @AuraEnabled public List<Id> taskIds;
    }

    @AuraEnabled(cacheable=true)
    public static List<OwnerWorkload> getOwnerWorkloads(List<Id> ownerIds) {
        if (ownerIds == null || ownerIds.isEmpty()) {
            return new List<OwnerWorkload>();
        }

        Map<Id, OwnerWorkload> byOwner = new Map<Id, OwnerWorkload>();
        for (Id ownerId : ownerIds) {
            OwnerWorkload row = new OwnerWorkload();
            row.ownerId = ownerId;
            row.openTaskCount = 0;
            row.overdueTaskCount = 0;
            row.openCaseCount = 0;
            row.openOpportunityCount = 0;
            row.openPipelineAmount = 0;
            byOwner.put(ownerId, row);
        }

        for (AggregateResult ar : [
            SELECT OwnerId ownerId, COUNT(Id) totalCount
            FROM Task
            WHERE OwnerId IN :ownerIds
                AND IsClosed = false
            GROUP BY OwnerId
        ]) {
            Id ownerId = (Id)ar.get('ownerId');
            byOwner.get(ownerId).openTaskCount = Integer.valueOf(String.valueOf(ar.get('totalCount')));
        }

        for (AggregateResult ar : [
            SELECT OwnerId ownerId, COUNT(Id) overdueCount
            FROM Task
            WHERE OwnerId IN :ownerIds
                AND IsClosed = false
                AND ActivityDate < :Date.today()
            GROUP BY OwnerId
        ]) {
            Id ownerId = (Id)ar.get('ownerId');
            byOwner.get(ownerId).overdueTaskCount = Integer.valueOf(String.valueOf(ar.get('overdueCount')));
        }

        for (AggregateResult ar : [
            SELECT OwnerId ownerId, COUNT(Id) totalCount
            FROM Case
            WHERE OwnerId IN :ownerIds
                AND IsClosed = false
            GROUP BY OwnerId
        ]) {
            Id ownerId = (Id)ar.get('ownerId');
            byOwner.get(ownerId).openCaseCount = Integer.valueOf(String.valueOf(ar.get('totalCount')));
        }

        for (AggregateResult ar : [
            SELECT OwnerId ownerId, COUNT(Id) totalCount, SUM(Amount) totalAmount
            FROM Opportunity
            WHERE OwnerId IN :ownerIds
                AND IsClosed = false
            GROUP BY OwnerId
        ]) {
            Id ownerId = (Id)ar.get('ownerId');
            OwnerWorkload row = byOwner.get(ownerId);
            row.openOpportunityCount = Integer.valueOf(String.valueOf(ar.get('totalCount')));
            Object totalAmount = ar.get('totalAmount');
            row.openPipelineAmount = (totalAmount == null) ? 0 : Decimal.valueOf(String.valueOf(totalAmount));
        }

        return byOwner.values();
    }

    @AuraEnabled
    public static ReassignResult reassignOverdueTasks(Id fromOwnerId, Id toOwnerId, Integer daysPastDue, Integer maxRecords) {
        if (fromOwnerId == null || toOwnerId == null) {
            throw new AuraHandledException('Both source and destination owners are required.');
        }
        if (fromOwnerId == toOwnerId) {
            throw new AuraHandledException('Source and destination owners must be different.');
        }

        Integer safeDaysPastDue = (daysPastDue == null || daysPastDue < 0) ? 0 : daysPastDue;
        Integer safeLimit = (maxRecords == null || maxRecords < 1) ? 200 : Math.min(maxRecords, 2000);
        Date dueBeforeDate = Date.today().addDays(-safeDaysPastDue);

        List<Task> toMove = [
            SELECT Id, OwnerId
            FROM Task
            WHERE OwnerId = :fromOwnerId
                AND IsClosed = false
                AND ActivityDate <= :dueBeforeDate
            ORDER BY ActivityDate ASC
            LIMIT :safeLimit
        ];

        List<Id> movedIds = new List<Id>();
        for (Task taskRecord : toMove) {
            taskRecord.OwnerId = toOwnerId;
            movedIds.add(taskRecord.Id);
        }

        if (!toMove.isEmpty()) {
            update toMove;
        }

        ReassignResult result = new ReassignResult();
        result.movedCount = toMove.size();
        result.taskIds = movedIds;
        return result;
    }
}