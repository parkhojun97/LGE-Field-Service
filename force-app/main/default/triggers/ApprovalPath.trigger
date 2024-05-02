/**************************************************************************************** 
 * File Name    : ApprovalPath.trigger
 * Author       : yohan.kang
 * Date         : 2020-09-18
 * Tester 		: ApprovalPath_test.cls
 * Description  :
 * Modification Log
 * =============================================================== 
 * Ver      Date 		Author    			Modification
 * ===============================================================
   1.0		2020-09-18 	yohan.kang			Create
****************************************************************************************/
trigger ApprovalPath on ApprovalPath__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
//	new Approvalpath_tr().run();
	// 2023-05-24 da.kim 동적 트리거핸들러 실행
	ApprovalTriggerHandler.runTriggerByCustomMeta(this);
}