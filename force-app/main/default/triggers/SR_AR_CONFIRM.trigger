/**
 * Created by A78914 on 2022-12-21.
 */

trigger SR_AR_CONFIRM on SR_AR_CONFIRM__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new FN_SrArConfirm_tr().run();
}