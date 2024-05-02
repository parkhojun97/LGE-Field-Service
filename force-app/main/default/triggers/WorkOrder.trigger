trigger WorkOrder on WorkOrder (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
//    new WorkOrder_tr().run();
    TriggerHandler.runTriggerByCustomMeta(this);
//    if(!Test.isRunningTest()) TriggerHandler.runTriggerByCustomMeta(this);
//    else new WorkOrder_tr().run();
}