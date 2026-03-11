@isTest
public class AppTestDataFactory {
    @TestVisible
    private static Integer sequence = 0;

    private static String nextToken() {
        sequence++;
        return String.valueOf(DateTime.now().getTime()) + '-' + String.valueOf(sequence);
    }

    public static List<Account> createAccounts(Integer count, Boolean doInsert) {
        List<Account> records = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            records.add(new Account(Name = 'Account-' + nextToken() + '-' + String.valueOf(i)));
        }
        if (doInsert && !records.isEmpty()) {
            insert records;
        }
        return records;
    }

    public static List<Contact> createContacts(Id accountId, Integer count, Boolean doInsert) {
        List<Contact> records = new List<Contact>();
        for (Integer i = 0; i < count; i++) {
            records.add(new Contact(
                AccountId = accountId,
                LastName = 'Contact-' + nextToken() + '-' + String.valueOf(i),
                Email = 'contact' + String.valueOf(i) + '@example.com'
            ));
        }
        if (doInsert && !records.isEmpty()) {
            insert records;
        }
        return records;
    }

    public static List<Opportunity> createOpenOpportunities(Id accountId, Integer count, Boolean doInsert) {
        List<Opportunity> records = new List<Opportunity>();
        for (Integer i = 0; i < count; i++) {
            records.add(new Opportunity(
                AccountId = accountId,
                Name = 'Opportunity-' + nextToken() + '-' + String.valueOf(i),
                StageName = 'Prospecting',
                Amount = 1000 + (i * 250),
                CloseDate = Date.today().addDays(10 + i)
            ));
        }
        if (doInsert && !records.isEmpty()) {
            insert records;
        }
        return records;
    }

    public static List<Case> createOpenCases(Id accountId, Integer count, Boolean doInsert) {
        List<Case> records = new List<Case>();
        for (Integer i = 0; i < count; i++) {
            records.add(new Case(
                AccountId = accountId,
                Subject = 'Case-' + nextToken() + '-' + String.valueOf(i),
                Origin = 'Phone',
                Status = 'New',
                Priority = 'Medium'
            ));
        }
        if (doInsert && !records.isEmpty()) {
            insert records;
        }
        return records;
    }

    public static List<Task> createOpenTasks(Id ownerId, Id whatId, Integer count, Boolean doInsert) {
        List<Task> records = new List<Task>();
        for (Integer i = 0; i < count; i++) {
            records.add(new Task(
                OwnerId = ownerId,
                WhatId = whatId,
                Subject = 'Task-' + nextToken() + '-' + String.valueOf(i),
                ActivityDate = Date.today(),
                Status = 'Not Started',
                Priority = 'Normal'
            ));
        }
        if (doInsert && !records.isEmpty()) {
            insert records;
        }
        return records;
    }

    public static List<Lead> createLeads(Integer count, Boolean doInsert) {
        List<Lead> records = new List<Lead>();
        for (Integer i = 0; i < count; i++) {
            records.add(new Lead(
                FirstName = 'Lead',
                LastName = 'Person-' + nextToken() + '-' + String.valueOf(i),
                Company = 'Company-' + String.valueOf(i),
                Email = 'lead' + String.valueOf(i) + '@example.com',
                Status = 'Open - Not Contacted'
            ));
        }
        if (doInsert && !records.isEmpty()) {
            insert records;
        }
        return records;
    }
}
