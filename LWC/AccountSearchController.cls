public with sharing class AccountSearchController {

    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccounts(String searchKey) {

        String key = '%' + searchKey + '%';

        return [
            SELECT Id, Name, Industry, Phone
            FROM Account
            WHERE Name LIKE :key
            LIMIT 10
        ];
    }
}

