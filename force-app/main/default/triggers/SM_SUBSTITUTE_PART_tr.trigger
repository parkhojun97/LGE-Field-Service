/************************************************************************************
* File Name   		: SM_SUBSTITUTE_PART_tr
* Description 		: 
* Modification Log
* Ver      Date            Author          Modification
* ===================================================================================
  1.0      2023-02-14     sangjae.lee         Create
*************************************************************************************/

trigger SM_SUBSTITUTE_PART_tr on SM_SUBSTITUTE_PART__c (before insert, before update, after insert, after update) {
  // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new SM_SUBSTITUTE_PART_trHandler().run();
}