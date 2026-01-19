public with sharing class AccountLwcHandlerClass {

    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountList() {

        return [
            SELECT Id, Name, Phone, Industry, Rating
            FROM Account
            ORDER BY CreatedDate DESC
            LIMIT 10
        ];
    }
}
