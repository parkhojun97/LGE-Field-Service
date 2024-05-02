trigger SM_COMMERCIAL_PRICE on SM_COMMERCIAL_PRICE__c  (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandler.runTriggerByCustomMeta(this);
}