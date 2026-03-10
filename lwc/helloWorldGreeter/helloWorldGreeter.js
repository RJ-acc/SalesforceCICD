import { LightningElement, track } from 'lwc';
import sayHello from '@salesforce/apex/HelloWorld.sayHello';

export default class HelloWorldGreeter extends LightningElement {
    @track name = '';
    @track greeting = '';
    @track error = '';

    handleNameChange(event) {
        this.name = event.target.value;
    }

    handleGreet() {
        sayHello({ name: this.name })
            .then(result => {
                this.greeting = result;
                this.error = '';
            })
            .catch(error => {
                this.error = error.body.message;
                this.greeting = '';
            });
    }
}