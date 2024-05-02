trigger SR_RESRV_PART_tr on SR_RESRV_PART__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
    TriggerHandler.runTriggerByCustomMeta(this);
    //new SR_RESRV_PART_tr().run();
}