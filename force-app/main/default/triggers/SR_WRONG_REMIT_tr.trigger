/************************************************************************************
* File Name           : SR_WRONG_REMIT_tr
* Description         : SR_WRONG_REMIT_tr
* Modification Log
* Ver      Date            Author          Modification
* ===================================================================================
1.0      2023-04-13       Sungho.Jo         Create
*************************************************************************************/
trigger SR_WRONG_REMIT_tr on SR_WRONG_REMIT__c (before insert, before update) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new SR_WRONG_REMIT_trHandler().run();
}