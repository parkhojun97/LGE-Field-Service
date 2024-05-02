/************************************************************************************
* File Name   		: TempUser_tr
* Description 		: 
* Modification Log
* Ver      Date            Author          Modification
* ===================================================================================
  1.0      2023-03-09        jihyun.lee         Create
*************************************************************************************/

trigger TempUser_tr on TempUser__c (before insert, before update, after insert, after update) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	  TriggerHandler.runTriggerByCustomMeta(this);
    //new TempUser_trHandler().run();
}