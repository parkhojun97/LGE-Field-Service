/************************************************************************************
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2023-04-07      jy.choi             Create
*************************************************************************************/

trigger Callback_tr on CallBack__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
//    new Callback_tr().run();
    // 2023-05-24 da.kim 동적 트리거핸들러 실행
    TriggerHandler.runTriggerByCustomMeta(this);
}