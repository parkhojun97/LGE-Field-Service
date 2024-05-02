/**
 * Created by A75685 on 2022-08-12.
 */

trigger VOC on VOC__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
    TriggerHandler.runTriggerByCustomMeta(this);
    //new VOC_tr().run();
}