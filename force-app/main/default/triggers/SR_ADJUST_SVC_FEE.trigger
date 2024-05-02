/**
 * Created by A78911 on 2023-02-09.
 */

trigger SR_ADJUST_SVC_FEE on SR_ADJUST_SVC_FEE__c (before insert, after insert) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new FN_SrAdjustSvcFee_tr().run();
}