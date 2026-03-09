import { LightningElement, track } from 'lwc';
import searchAccounts from '@salesforce/apex/AccountService.searchAccounts';
export default class AccountSearch extends LightningElement {
    @track searchKey = ''; @track accounts = []; @track error; @track isSearching = false;
    handleSearchChange(event) { this.searchKey = event.target.value; }
    handleSearch() {
        if (this.searchKey.length < 2) { this.error = 'Enter at least 2 characters'; return; }
        this.isSearching = true;
        searchAccounts({ searchKey: this.searchKey })
            .then(result => { this.accounts = result; this.isSearching = false; this.error = result.length === 0 ? 'No accounts found' : undefined; })
            .catch(error => { this.error = error.body.message; this.accounts = []; this.isSearching = false; });
    }
    handleKeyUp(event) { if (event.keyCode === 13) this.handleSearch(); }
    get hasResults() { return this.accounts.length > 0; }
}