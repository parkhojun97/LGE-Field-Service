/**
 * Created by 85243 on 2022-12-22.
 */

trigger SM_HOLIDAY_MASTER_tr on SM_HOLIDAY_MASTER__c (before insert, before update, after insert, after update) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new SM_HOLIDAY_MASTER_trHandler().run();
}