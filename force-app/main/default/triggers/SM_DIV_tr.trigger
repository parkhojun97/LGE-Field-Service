/************************************************************************************
* File Name   		: SM_DIV_tr
* Description 		: 
* Modification Log
* Ver      Date            Author          Modification
* ===================================================================================
  1.0      2023-01-03     sangjae.lee         Create
*************************************************************************************/

trigger SM_DIV_tr on SM_DIV__c (before insert, before update, after insert, after update) {
  // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new SM_DIV_trHandler().run();
}