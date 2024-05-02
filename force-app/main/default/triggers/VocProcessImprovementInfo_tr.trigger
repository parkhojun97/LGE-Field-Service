/************************************************************************************
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2023-07-24      jy.choi             Create
*************************************************************************************/

trigger VocProcessImprovementInfo_tr on VOC_Process_Improvement_Info__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    TriggerHandler.runTriggerByCustomMeta(this);
//    new VocProcessImprovementInfo_tr().run();
}