/**
 * Created by A78911 on 2023-03-09.
 */

trigger SM_REPAIR_COST_BUNDLE on SM_REPAIR_COST_BUNDLE__c (before update, after update) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new FN_SmRepairCostBundle_tr().run();

}