/**
 * Created by A78911 on 2023-03-08.
 */

trigger SM_REPAIR_COST_HISTORY on SM_REPAIR_COST_HISTORY__c (before insert, before update, after insert, after update) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new FN_SmRepairCostHistory_tr().run();

}