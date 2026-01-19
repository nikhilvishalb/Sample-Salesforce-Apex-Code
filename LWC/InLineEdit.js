import { LightningElement, track, wire } from 'lwc';
import getAccounts from '@salesforce/apex/AccountInlineEditController.getAccounts';
import updateAccounts from '@salesforce/apex/AccountInlineEditController.updateAccounts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AccountInlineEdit extends LightningElement {
  
    @track accounts = [];
    @track draftValues = [];

    // Datatable columns (Industry + Phone are editable)
    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Industry', fieldName: 'Industry', editable: true },
        { label: 'Phone', fieldName: 'Phone', editable: true }
    ];

    @wire(getAccounts)
    WiredData({ data, error }) {

        if (data) {
            this.accounts = data;
        }

        if (error) {
            console.log('Error while loading accounts:', error);
        }
    }
    handleSave(event) {
        let editedRecords = event.detail.draftValues;
        updateAccounts({ accountList: editedRecords })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Accounts updated successfully',
                        variant: 'success'
                    })
                );
                this.draftValues = [];            
                return getAccounts();
            })
            .then((result) => {
                this.accounts = result;
            })
            .catch((error) => {
                console.log('Error while updating accounts:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Update failed',
                        variant: 'error'
                    })
                );
            });
    }
}
