@isTest
public class PipelineOpsServiceTest {
    @isTest static void testGetOwnerWorkloadsAndReassign() {
        User actingUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Account accountRecord = AppTestDataFactory.createAccounts(1, true)[0];

        List<Task> openTasks = AppTestDataFactory.createOpenTasks(actingUser.Id, accountRecord.Id, 3, true);
        for (Task taskRecord : openTasks) {
            taskRecord.ActivityDate = Date.today().addDays(-2);
        }
        update openTasks;

        insert new Case(
            AccountId = accountRecord.Id,
            Subject = 'Open support case',
            Origin = 'Phone',
            Status = 'New',
            Priority = 'Medium',
            OwnerId = actingUser.Id
        );

        insert new Opportunity(
            AccountId = accountRecord.Id,
            Name = 'Open Deal',
            StageName = 'Prospecting',
            Amount = 12000,
            CloseDate = Date.today().addDays(10),
            OwnerId = actingUser.Id
        );

        List<PipelineOpsService.OwnerWorkload> workloads = PipelineOpsService.getOwnerWorkloads(new List<Id>{ actingUser.Id });
        System.assertEquals(1, workloads.size());
        System.assertEquals(3, workloads[0].openTaskCount);
        System.assertEquals(3, workloads[0].overdueTaskCount);
        System.assertEquals(1, workloads[0].openCaseCount);
        System.assertEquals(1, workloads[0].openOpportunityCount);
        System.assert(workloads[0].openPipelineAmount > 0);
    }

    @isTest static void testReassignValidation() {
        User actingUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Boolean didThrow = false;

        try {
            PipelineOpsService.reassignOverdueTasks(actingUser.Id, actingUser.Id, 1, 5);
        } catch (AuraHandledException ex) {
            didThrow = true;
        }
        System.assert(didThrow);
    }

    @isTest static void testReassignToQueue() {
        Account accountRecord = AppTestDataFactory.createAccounts(1, true)[0];
        Id fromOwnerId = UserInfo.getUserId();

        Group taskQueue = new Group(
            Name = 'Task Ops Queue',
            Type = 'Queue'
        );
        insert taskQueue;

        insert new QueueSobject(
            QueueId = taskQueue.Id,
            SobjectType = 'Task'
        );

        List<Task> openTasks = AppTestDataFactory.createOpenTasks(fromOwnerId, accountRecord.Id, 2, true);
        for (Task taskRecord : openTasks) {
            taskRecord.ActivityDate = Date.today().addDays(-1);
        }
        update openTasks;

        Test.startTest();
        PipelineOpsService.ReassignResult result =
            PipelineOpsService.reassignOverdueTasks(fromOwnerId, taskQueue.Id, 1, 20);
        Test.stopTest();

        System.assertEquals(2, result.movedCount);

        Integer queueOwnedTasks = [
            SELECT COUNT()
            FROM Task
            WHERE Id IN :openTasks
                AND OwnerId = :taskQueue.Id
        ];
        System.assertEquals(2, queueOwnedTasks);
    }
}