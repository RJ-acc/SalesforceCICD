public with sharing class ContactManager {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts() {
        return [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WITH USER_MODE LIMIT 10];
    }

    @AuraEnabled
    public static Contact createContact(String firstName, String lastName, String email, String phone) {
        Contact c = new Contact(
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            Phone = phone
        );
        Database.insert(c, AccessLevel.USER_MODE);
        return c;
    }

    @AuraEnabled
    public static void deleteContact(Id contactId) {
        Contact c = [SELECT Id FROM Contact WHERE Id = :contactId WITH USER_MODE LIMIT 1];
        Database.delete(c, AccessLevel.USER_MODE);
    }
}
