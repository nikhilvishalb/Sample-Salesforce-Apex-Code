trigger Lead_AfterUpdate on Lead (after update) {
    Lead_AfterUpdate_Handler.run(Trigger.new, Trigger.oldMap);
}
