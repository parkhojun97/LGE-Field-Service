/************************************************************************************
 * Description :
 * 
 * Ver      Date           Author          Modification
 * ===================================================================================
   1.0      2023-10-26        tk.kim         Create
*************************************************************************************/
trigger DisposalMaster_tr on DISPOSAL_Master__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
    TriggerHandler.runTriggerByCustomMeta(this);
}