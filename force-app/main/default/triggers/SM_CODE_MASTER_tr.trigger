/************************************************************************************
* File Name         : SM_CODE_MASTER_tr
* Description       : 
* Modification Log
* Ver      Date            Author          Modification
* ===================================================================================
  1.0      2023-03-15     sangjae.lee         Create
*************************************************************************************/

trigger SM_CODE_MASTER_tr on SM_CODE_MASTER__c (before insert, before update, after insert, after update) {
  // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new SM_CODE_MASTER_trHandler().run();
}