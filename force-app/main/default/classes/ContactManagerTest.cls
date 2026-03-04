@isTest
public class ContactManagerTest {
    @isTest
    static void testGetContacts() {
        Contact c = new Contact(FirstName = 'Test', LastName = 'User', Email = 'test@example.com');
        insert c;

        List<Contact> contacts = ContactManager.getContacts();
        System.assert(contacts.size() > 0, 'Should return at least one contact');
    }

    @isTest
    static void testCreateContact() {
        Contact c = ContactManager.createContact('John', 'Doe', 'john@example.com', '1234567890');
        System.assertNotEquals(null, c.Id, 'Contact should be created');
        System.assertEquals('John', c.FirstName);
        System.assertEquals('Doe', c.LastName);
    }

    @isTest
    static void testDeleteContact() {
        Contact c = new Contact(FirstName = 'Delete', LastName = 'Me');
        insert c;

        ContactManager.deleteContact(c.Id);

        List<Contact> remaining = [SELECT Id FROM Contact WHERE Id = :c.Id];
        System.assertEquals(0, remaining.size(), 'Contact should be deleted');
    }
}