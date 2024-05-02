/******************************************************************
  * File Name   : SR_SCHEDULE_tr
  * Description : 
  * Author      : won.suh
  * Modification Log
  * ===============================================================
  * Ver  Date           Author          Modification
  * ===============================================================
    1.0  2023-05-09     won.suh         Create
******************************************************************/

trigger SR_SCHEDULE_tr on SR_SCHEDULE__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
  // 2023-05-23 Trigger handler On/OFF 공통 대체
  TriggerHandler.runTriggerByCustomMeta(this);
  //new SR_SCHEDULE_trHandler().run();
}