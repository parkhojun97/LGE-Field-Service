/**
 * File Name    : ApprovalConfigSummary.cls
 * Author       : yohan.kang
 * Date         : 2021-07-08
 * Tester       : ApprovalConfigSummary_test.cls
 * Description  : 
 * Modification Log
 * ======================================================================================
 * Ver      Date        Author              Modification
 * ======================================================================================
 * 1.0      2021-07-08  yohan.kang          Create
 */
trigger ApprovalConfigSummary on ApprovalConfigSummary__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
//	new ApprovalConfigSummary_tr().run();
	// 2023-05-24 da.kim 동적 트리거핸들러 실행
	ApprovalTriggerHandler.runTriggerByCustomMeta(this);
}