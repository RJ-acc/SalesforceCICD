public with sharing class TaskService {
    @AuraEnabled(cacheable=true)
    public static List<Task> getMyTasks() {
        return [SELECT Id, Subject, Status, Priority, ActivityDate, Who.Name, What.Name, Description FROM Task WHERE OwnerId = :UserInfo.getUserId() AND IsClosed = false ORDER BY ActivityDate ASC LIMIT 50];
    }
    @AuraEnabled
    public static Task createTask(String subject, String priority, Date dueDate, Id whoId, Id whatId, String description) {
        Task t = new Task(Subject = subject, Priority = priority, ActivityDate = dueDate, WhoId = whoId, WhatId = whatId, Description = description, Status = 'Not Started');
        insert t; return t;
    }
    @AuraEnabled
    public static Task completeTask(Id taskId) {
        Task t = [SELECT Id FROM Task WHERE Id = :taskId LIMIT 1]; t.Status = 'Completed'; update t; return t;
    }
    @AuraEnabled(cacheable=true)
    public static List<Task> getOverdueTasks() {
        return [SELECT Id, Subject, ActivityDate, Priority, Who.Name, What.Name FROM Task WHERE ActivityDate < TODAY AND IsClosed = false AND OwnerId = :UserInfo.getUserId() ORDER BY ActivityDate ASC LIMIT 20];
    }
}