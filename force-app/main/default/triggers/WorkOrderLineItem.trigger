trigger WorkOrderLineItem on WorkOrderLineItem__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandler.runTriggerByCustomMeta(this);
}