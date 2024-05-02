/**
 * File Name    : ServiceRcptLockInfo.cls
 * Author       : Yohan.Kang
 * Date         : 2024-02-22
 * Tester       : ServiceRcptLockInfo_tr_test.cls
 * Description  : 
 * Modification Log
 * ======================================================================================
 * Ver      Date        Author              Modification
 * ======================================================================================
 * 1.0      2024-02-22  Yohan.Kang          Create
 */
trigger ServiceRcptLockInfo on ServiceRcptLockInfo__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	TriggerHandler.runTriggerByCustomMeta(this);
}