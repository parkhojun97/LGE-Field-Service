/**
 * File Name    : ProductLiability.trigger
 * Author       : da.kim
 * Date         : 2023-10-17
 * Tester       : ProductLiability_tr_test.cls
 * Description  : PL 트리거
 * Modification Log
 * ======================================================================================
 * Ver      Date            Author              Modification
 * ======================================================================================
 * 1.0      2023-10-17      da.kim              Create
**/
trigger ProductLiability on Product_Liability__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandler.runTriggerByCustomMeta(this);
}