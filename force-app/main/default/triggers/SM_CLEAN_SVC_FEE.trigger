/**
 * Created by A78911 on 2023-03-21.
 */

trigger SM_CLEAN_SVC_FEE on SM_CLEAN_SVC_FEE__c (before insert, after insert, before update, after update) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new FN_SmCleanSvcFee_tr().run();
}