import { LightningElement } from 'lwc';
import searchAccounts from '@salesforce/apex/AccountService.searchAccounts';

export default class AccountSearch extends LightningElement {
    searchKey = '';
    accounts = [];
    error;
    isSearching = false;

    handleSearchChange(event) {
        this.searchKey = event.target.value;
    }

    handleSearch() {
        if (this.searchKey.length < 2) {
            this.error = 'Enter at least 2 characters';
            return;
        }

        this.isSearching = true;

        searchAccounts({ searchKey: this.searchKey })
            .then((result) => {
                this.accounts = result;
                this.isSearching = false;
                this.error = result.length === 0 ? 'No accounts found' : undefined;
            })
            .catch((error) => {
                this.error = error?.body?.message || 'Unable to search accounts';
                this.accounts = [];
                this.isSearching = false;
            });
    }

    handleKeyUp(event) {
        if (event.key === 'Enter') {
            this.handleSearch();
        }
    }

    get hasResults() {
        return this.accounts.length > 0;
    }
}
