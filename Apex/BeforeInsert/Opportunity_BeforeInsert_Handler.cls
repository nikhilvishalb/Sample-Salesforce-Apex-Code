public class Opportunity_BeforeInsert_Handler {
/*Requirement
  1. If the user does not enter CloseDate, automatically set it to 30 days from today.
  2. If the Opportunity StageName = "Closed Won", then Amount must be greater than 0. Otherwise, block the record with an error.
  3. Under the same Account, users should not be able to create another Opportunity with the same Name (case-insensitive). 
  If a duplicate exists, stop insert and show an error.*/
    
public static void run(List<Opportunity> newOppList) {

        //Collect AccountIds
        Set<Id> accountIdSet = new Set<Id>();
        for(Opportunity opp : newOppList){

            if(opp.AccountId != null){
                accountIdSet.add(opp.AccountId);
            }
        }

        //Query existing Opportunities
        List<Opportunity> existingOppList = new List<Opportunity>();

        if(!accountIdSet.isEmpty()){

            existingOppList = [
                SELECT Id, Name, AccountId
                FROM Opportunity
                WHERE AccountId IN :accountIdSet
            ];
        }

        // map for duplicate check
        Map<String, Opportunity> keyToExistingOppMap = new Map<String, Opportunity>();

        for(Opportunity exOpp : existingOppList){
            if(exOpp.AccountId == null || String.isBlank(exOpp.Name)){
                continue;
            }

            String key = exOpp.AccountId + '||' + exOpp.Name.trim().toLowerCase();
            keyToExistingOppMap.put(key, exOpp);
        }

        // Apply validations + default values
        for(Opportunity opp : newOppList){

            if(opp.CloseDate == null){
                opp.CloseDate = Date.today().addDays(30);
            }
            if(opp.StageName == 'Closed Won'){

                if(opp.Amount == null || opp.Amount <= 0){
                    opp.addError('Amount must be greter than 0 when Stage is Closed Won.');
                }
            }
            if(opp.AccountId != null && String.isNotBlank(opp.Name)){

                String key = opp.AccountId + '-' + opp.Name.trim().toLowerCase();

                if(keyToExistingOppMap.containsKey(key)){
                    opp.addError('Duplicate Opportunity Name under the same Account is not allowed.');
                }
            }
        }
    }
}
