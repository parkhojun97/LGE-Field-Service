/**************************************************************************************** 
 * File Name    : Approval.trigger
 * Author       : yohan.kang
 * Date         : 2020-08-25
 * Tester       : Approval_test.cls
 * Description  :
 * Modification Log
 * =============================================================== 
 * Ver      Date        Author              Modification
 * ===============================================================
   1.0      2020-08-25  yohan.kang          Create
   1.1    2021-06-28  da.kim          PJ190373B-24659 Trigger Handler Setting 메타데이터에 등록된 핸들러 사용
****************************************************************************************/
trigger Approval on Approval__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
//   new Approval_tr().run();
    // 2023-05-24 da.kim 동적 트리거핸들러 실행
    ApprovalTriggerHandler.runTriggerByCustomMeta(this);
}