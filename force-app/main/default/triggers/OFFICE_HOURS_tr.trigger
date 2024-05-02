/************************************************************************************
* File Name   		: OFFICE_HOURS_tr
* Description 		: 
* Modification Log
* Ver      Date            Author          Modification
* ===================================================================================
  1.0      2023-03-17     sangjae.lee         Create
*************************************************************************************/

trigger OFFICE_HOURS_tr on OFFICE_HOURS__c (before insert, before update, after insert, after update) {
//    new OFFICE_HOURS_trHandler().run();
    // 2023-05-24 da.kim 동적 트리거핸들러 실행
    TriggerHandler.runTriggerByCustomMeta(this);
}