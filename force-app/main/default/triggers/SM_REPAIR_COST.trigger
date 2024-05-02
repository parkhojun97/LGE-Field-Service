/**
 * Created by A78911 on 2023-03-09.
 */

trigger SM_REPAIR_COST on SM_REPAIR_COST__c (before insert, before update, after insert) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new FN_SmRepairCost_tr().run();

}