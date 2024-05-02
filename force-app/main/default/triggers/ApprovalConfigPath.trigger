/**************************************************************************************** 
 * File Name    : ApprovalConfigPath.trigger
 * Author       : yohan.kang
 * Date         : 2020-09-02
 * Tester 		: ApprovalConfigPath_test.cls
 * Description  :
 * Modification Log
 * =============================================================== 
 * Ver      Date 		Author    			Modification
 * ===============================================================
   1.0		2020-09-02 	yohan.kang			Create
****************************************************************************************/
trigger ApprovalConfigPath on ApprovalConfigPath__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
//	new ApprovalConfigPath_tr().run();
	// 2023-05-24 da.kim 동적 트리거핸들러 실행
	ApprovalTriggerHandler.runTriggerByCustomMeta(this);
}