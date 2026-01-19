public class Lead_AfterUpdate_Handler {

/*Requirment:
If the Lead Owner changes (OwnerId is updated), create a handover Task for the new owner.
Task details:
Subject: Lead Handover - Review and Contact
Status: Not Started
Priority: High
Due Date: Tomorrow
To avoid spam, do not create the Task if a Task with the same Subject already exists for that Lead in the last 24 hours. */

    public static void run(List<Lead> newLeadList, Map<Id, Lead> oldLeadMap) {
        String handoverSubject = 'Lead Handover - Review and Contact';

        //Find leads where OwnerId changed       
        Set<Id> leadIdSet = new Set<Id>();
        for(Lead newLd : newLeadList){
            Lead oldLd = oldLeadMap.get(newLd.Id);
            if(newLd.OwnerId != oldLd.OwnerId){
                leadIdSet.add(newLd.Id);
            }
        }

        if(leadIdSet.isEmpty()){
            return;
        }    

        //Check if handover task already exists in last 24 hours        
        Set<Id> leadIdWithRecentTaskSet = new Set<Id>();
        DateTime last24Hours = System.now().addHours(-24);
        List<Task> existingTaskList = [
            SELECT Id, WhoId, CreatedDate, Subject
            FROM Task
            WHERE WhoId IN :leadIdSet
            AND Subject = :handoverSubject
            AND CreatedDate >= :last24Hours
        ];

        for(Task t : existingTaskList){
            if(t.WhoId != null){
                leadIdWithRecentTaskSet.add(t.WhoId);
            }
        }

        
        //create handover task only
        
        List<Task> taskListToInsert = new List<Task>();
        for(Lead newLd : newLeadList){
            Lead oldLd = oldLeadMap.get(newLd.Id);
            if(newLd.OwnerId == oldLd.OwnerId){
                continue;
            }

            if(leadIdWithRecentTaskSet.contains(newLd.Id)){
                continue;
            }
            Task t = new Task();
            t.OwnerId = newLd.OwnerId;     // new owner
            t.WhoId = newLd.Id;            // Lead
            t.Subject = handoverSubject;
            t.Status = 'Not Started';
            t.Priority = 'High';
            t.ActivityDate = Date.today().addDays(1);

            taskListToInsert.add(t);
        }

        if(!taskListToInsert.isEmpty()){
            insert taskListToInsert;
        }
    }
}
