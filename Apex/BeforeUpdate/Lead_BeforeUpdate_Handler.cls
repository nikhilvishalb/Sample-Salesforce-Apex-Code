public class Lead_BeforeUpdate_Handler {

/*Requirment:
1. If a Lead’s Status is changed to “Qualified”, then Company must be filled. Otherwise, block the update with an error.
2. If LeadSource = “Web” and Rating is blank, automatically set Rating = “Hot”.
3. If the Email is changed, block public email domains like gmail.com, yahoo.com, outlook.com and show an error asking for a business email. */

    public static void run(List<Lead> newLeadList, Map<Id, Lead> oldLeadMap) {

        // Public domains (example list)
        Set<String> blockedDomainSet = new Set<String>{
            'gmail.com', 'yahoo.com', 'outlook.com'
        };

        for(Lead newLd : newLeadList){
            Lead oldLd = oldLeadMap.get(newLd.Id);
            if(newLd.Status != oldLd.Status && newLd.Status == 'Qualified'){
                if(String.isBlank(newLd.Company)){
                    newLd.addError('Company is required when Lead Status is Qualified.');
                }
            }

            //If LeadSource = Web and Rating is empty
            if(newLd.LeadSource == 'Web' && String.isBlank(newLd.Rating)){
                newLd.Rating = 'Hot';
            }

            // Email changed, block public email domains
            if(newLd.Email != oldLd.Email && String.isNotBlank(newLd.Email)){
                String emailLower = newLd.Email.trim().toLowerCase();
                if(emailLower.contains('@')){
                    String domain = emailLower.substringAfter('@');
                    if(blockedDomainSet.contains(domain)){
                        newLd.addError('Please use a business email address (public domains are not allowed).');
                    }
                }
            }
        }
    }
}
