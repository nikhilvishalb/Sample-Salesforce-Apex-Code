public class Opportunity_AfterInsert_Handler {

/*Requirement:
1. When a new Opportunity is created, the system should create a follow-up Task for the Opportunity Owner.
2. Create only one Task per Account per day (even if multiple Opportunities are created for the same Account on the same day).
3. Subject: Follow up on today’s new Opportunities
4. Status: Not Started
5. Due Date: Tomorrow */

    public static void run(List<Opportunity> newOppList) {


        //Collect AccountIds
        Set<Id> accountIdSet = new Set<Id>();

        for(Opportunity opp : newOppList){
            if(opp.AccountId != null){
                accountIdSet.add(opp.AccountId);
            }
        }

        if(accountIdSet.isEmpty()){
            return;
        }


        //Find Accounts that already have a Task created today
        Set<Id> accountIdWithTodayTaskSet = new Set<Id>();

        List<Task> todayTaskList = [
            SELECT Id, WhatId, CreatedDate
            FROM Task
            WHERE WhatId IN :accountIdSet
            AND CreatedDate = TODAY
        ];

        for(Task t : todayTaskList){
            if(t.WhatId != null){
                accountIdWithTodayTaskSet.add(t.WhatId);
            }
        }


        //Create Task only once per Account

        Set<Id> accountIdTaskCreatedInThisRunSet = new Set<Id>();
        List<Task> taskListToInsert = new List<Task>();

        for(Opportunity opp : newOppList){

            if(opp.AccountId == null){
                continue;
            }
            if(accountIdWithTodayTaskSet.contains(opp.AccountId)){
                continue;
            }
            if(accountIdTaskCreatedInThisRunSet.contains(opp.AccountId)){
                continue;
            }

            Task t = new Task();
            t.OwnerId = opp.OwnerId;
            t.WhatId = opp.AccountId; // Task is linked to Account
            t.Subject = 'Follow up on today\'s new Opportunities';
            t.Status = 'Not Started';
            t.Priority = 'Normal';
            t.ActivityDate = Date.today().addDays(1);

            taskListToInsert.add(t);
            accountIdTaskCreatedInThisRunSet.add(opp.AccountId);
        }

        if(!taskListToInsert.isEmpty()){
            insert taskListToInsert;
        }
    }
}
