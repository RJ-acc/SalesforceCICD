import { LightningElement, wire } from 'lwc';
import createContact from '@salesforce/apex/ContactManager.createContact';
import deleteContact from '@salesforce/apex/ContactManager.deleteContact';
import getContacts from '@salesforce/apex/ContactManager.getContacts';
import { refreshApex } from '@salesforce/apex';

export default class ContactManager extends LightningElement {
    contacts = [];
    error;
    firstName = '';
    lastName = '';
    email = '';
    phone = '';
    showForm = false;

    wiredContactsResult;

    @wire(getContacts)
    wiredContacts(result) {
        this.wiredContactsResult = result;
        if (result.data) {
            this.contacts = result.data;
            this.error = null;
        } else if (result.error) {
            this.error = result.error.body.message;
            this.contacts = [];
        }
    }

    handleInputChange(event) {
        const { field } = event.target.dataset,
            { value } = event.target;
        if (field === 'firstName') {
            this.firstName = value;
        }
        if (field === 'lastName') {
            this.lastName = value;
        }
        if (field === 'email') {
            this.email = value;
        }
        if (field === 'phone') {
            this.phone = value;
        }
    }

    toggleForm() {
        this.showForm = !this.showForm;
    }

    handleCreate() {
        createContact({
            email: this.email,
            firstName: this.firstName,
            lastName: this.lastName,
            phone: this.phone
        })
            .then(() => {
                this.firstName = '';
                this.lastName = '';
                this.email = '';
                this.phone = '';
                this.showForm = false;
                return refreshApex(this.wiredContactsResult);
            })
            .catch((error) => {
                this.error = error?.body?.message || 'Unable to create contact';
            });
    }

    handleDelete(event) {
        const contactId = event.target.dataset.id;

        deleteContact({ contactId })
            .then(() => refreshApex(this.wiredContactsResult))
            .catch((error) => {
                this.error = error?.body?.message || 'Unable to delete contact';
            });
    }
}