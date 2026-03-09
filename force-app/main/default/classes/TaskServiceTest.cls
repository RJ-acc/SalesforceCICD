@isTest
public class TaskServiceTest {
    @TestSetup static void setupData() {
        List<Task> tasks = new List<Task>();
        for (Integer i = 0; i < 5; i++) tasks.add(new Task(Subject = 'Task ' + i, Priority = 'Normal', ActivityDate = Date.today().addDays(i - 2), Status = 'Not Started'));
        insert tasks;
    }
    @isTest static void testGetMyTasks() { System.assertNotEquals(null, TaskService.getMyTasks()); }
    @isTest static void testCreate() { System.assertNotEquals(null, TaskService.createTask('Call', 'High', Date.today().addDays(5), null, null, 'Follow up').Id); }
    @isTest static void testComplete() { Task t = [SELECT Id FROM Task WHERE Status = 'Not Started' LIMIT 1]; System.assertEquals('Completed', TaskService.completeTask(t.Id).Status); }
    @isTest static void testOverdue() { System.assertNotEquals(null, TaskService.getOverdueTasks()); }
}