/**************************************************************************************** 
 * File Name    : SM_PART_CLASS.trigger
 * Author       : sangjae.lee
 * Date         : 2022-08-18
 * Tester       : SM_PART_CLASS.cls
 * Description  :
 * Modification Log
 * =============================================================== 
 * Ver      Date        Author              Modification
 * ===============================================================
   1.0      2022-08-18  sangjae.lee         Create
****************************************************************************************/
trigger SM_PART_CLASS_tr on SM_PART_CLASS__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
  // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new SM_PART_CLASS_trHandler().run();
}