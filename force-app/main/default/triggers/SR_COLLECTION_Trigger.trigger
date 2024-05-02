/**
 * Created by pttc on 2/9/23.
 */

trigger SR_COLLECTION_Trigger on SR_COLLECTION__c (before insert, before update, after insert, after update) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new FN_SR_COLLECTION_tr().run();
}