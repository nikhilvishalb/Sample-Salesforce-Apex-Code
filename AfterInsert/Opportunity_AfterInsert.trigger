trigger Opportunity_AfterInsert on Opportunity (after insert) {
    Opportunity_AfterInsert_Handler.run(Trigger.new);
}

