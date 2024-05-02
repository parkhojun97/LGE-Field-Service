/******************************************************************
  * File Name   : SM_SCHEDULER_tr
  * Description : 
  * Author      : won.suh
  * Modification Log
  * ===============================================================
  * Ver  Date           Author          Modification
  * ===============================================================
    1.0  2023-08-08     won.suh         Create
******************************************************************/

trigger SM_SCHEDULER_tr on SM_SCHEDULER__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandler.runTriggerByCustomMeta(this);
}