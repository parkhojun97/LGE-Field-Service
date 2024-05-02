/**
 * Created by A78914 on 2023-03-13.
 */

trigger SR_COLLECTION_DETAIL_Trigger on SR_COLLECTION_DETAIL__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new FN_SrCollectionDetail_tr().run();
}