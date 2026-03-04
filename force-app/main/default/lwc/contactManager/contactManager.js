import { LightningElement, wire, track } from 'lwc';
import getContacts from '@salesforce/apex/ContactManager.getContacts';
import createContact from '@salesforce/apex/ContactManager.createContact';
import deleteContact from '@salesforce/apex/ContactManager.deleteContact';
import { refreshApex } from '@salesforce/apex';

export default class ContactManager extends LightningElement {
    @track contacts = [];
    @track error;
    @track firstName = '';
    @track lastName = '';
    @track email = '';
    @track phone = '';
    @track showForm = false;

    wiredContactsResult;

    @wire(getContacts)
    wiredContacts(result) {
        this.wiredContactsResult = result;
        if (result.data) {
            this.contacts = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error.body.message;
            this.contacts = [];
        }
    }

    handleInputChange(event) {
        const field = event.target.dataset.field;
        if (field === 'firstName') this.firstName = event.target.value;
        if (field === 'lastName') this.lastName = event.target.value;
        if (field === 'email') this.email = event.target.value;
        if (field === 'phone') this.phone = event.target.value;
    }

    toggleForm() {
        this.showForm = !this.showForm;
    }

    handleCreate() {
        createContact({ firstName: this.firstName, lastName: this.lastName, email: this.email, phone: this.phone })
            .then(() => {
                this.firstName = '';
                this.lastName = '';
                this.email = '';
                this.phone = '';
                this.showForm = false;
                return refreshApex(this.wiredContactsResult);
            })
            .catch(error => {
                this.error = error.body.message;
            });
    }

    handleDelete(event) {
        const contactId = event.target.dataset.id;
        deleteContact({ contactId: contactId })
            .then(() => {
                return refreshApex(this.wiredContactsResult);
            })
            .catch(error => {
                this.error = error.body.message;
            });
    }
}