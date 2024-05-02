/************************************************************************************
 * Ver      Date            Author              Modification
 * ===================================================================================
   1.0      2023-08-19      jy.choi             Create
*************************************************************************************/

trigger Discretion_tr on Discretion__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new Discretion_tr().run();
}