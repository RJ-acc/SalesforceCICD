import { LightningElement } from 'lwc';
import searchAccounts from '@salesforce/apex/AccountService.searchAccounts';

const MIN_SEARCH_CHARS = 2,
    ZERO = 0;

export default class AccountSearch extends LightningElement {
    searchKey = '';
    accounts = [];
    error;
    isSearching = false;

    handleSearchChange(event) {
        this.searchKey = event.target.value;
    }

    handleSearch() {
        if (this.searchKey.length < MIN_SEARCH_CHARS) {
            this.error = 'Enter at least 2 characters';
            return;
        }

        this.isSearching = true;

        searchAccounts({ searchKey: this.searchKey })
            .then((result) => {
                this.accounts = result;
                this.isSearching = false;
                this.error = null;
                if (result.length === ZERO) {
                    this.error = 'No accounts found';
                }
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
        return this.accounts.length > ZERO;
    }
}
