import { LightningElement, track } from 'lwc';
import searchAccounts from '@salesforce/apex/AccountSearchController.searchAccounts';

export default class AccountSearchDatatable extends LightningElement {

    searchKey = '';
    @track accounts = [];
    error = null;

    columns = [
        { label: 'Account Name', fieldName: 'Name' },
        { label: 'Industry', fieldName: 'Industry' },
        { label: 'Phone', fieldName: 'Phone' }
    ];

    handleChange(event) {

        this.searchKey = event.target.value;
      
        if (this.searchKey == null || this.searchKey.trim() == '') {
            this.accounts = [];
            this.error = null;
            return;
        }

        searchAccounts({ searchKey: this.searchKey })
            .then((result) => {
                this.accounts = result;
                this.error = null;
            })
            .catch((err) => {
                this.accounts = [];

                if (err && err.body && err.body.message) {
                    this.error = err.body.message;
                } else {
                    this.error = 'Error while searching accounts';
                }
            });
    }
}
