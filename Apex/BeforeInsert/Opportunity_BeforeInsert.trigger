trigger Opportunity_BeforeInsert on Opportunity (before insert) {
    Opportunity_BeforeInsert_Handler.run(Trigger.new);
}

