/**
 * Created by I2MAX.SEUNGHUNAN on 2023-04-28.
 */

trigger SR_ONLINE_DELIVERY_INFO_HISTORY on SR_ONLINE_DELIVERY_INFO_HISTORY__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new SR_ONLINE_DELIVERY_INFO_HISTORY_tr().run();
}