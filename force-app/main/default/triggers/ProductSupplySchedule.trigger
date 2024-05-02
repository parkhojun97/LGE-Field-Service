/**
 * File Name    : ProductSupplySchedule.cls
 * Author       : Yohan.Kang
 * Date         : 2023-12-18
 * Tester       : ProductSupplySchedule_tr_test.cls
 * Description  : 
 * Modification Log
 * ======================================================================================
 * Ver      Date        Author              Modification
 * ======================================================================================
 * 1.0      2023-12-18  Yohan.Kang          Create
 */
trigger ProductSupplySchedule on ProductSupplySchedule__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	TriggerHandler.runTriggerByCustomMeta(this);
}