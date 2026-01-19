trigger Lead_BeforeUpdate on Lead (before update) {
    Lead_BeforeUpdate_Handler.run(Trigger.new, Trigger.oldMap);
}
