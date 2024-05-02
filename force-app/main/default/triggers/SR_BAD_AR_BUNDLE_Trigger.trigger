/**
 * Created by pttc on 12/27/22.
 */

trigger SR_BAD_AR_BUNDLE_Trigger on SR_BAD_AR_BUNDLE__c (before insert, before update, after insert, after update) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new FN_SR_BAD_AR_BUNDLE_tr().run();
}