/******************************************************************
  * File Name   : NewResourceAbsence_tr
  * Description : 
  * Author      : won.suh
  * Modification Log
  * ===============================================================
  * Ver  Date           Author          Modification
  * ===============================================================
    1.0  2024-03-06     won.suh         Create
******************************************************************/

trigger NewResourceAbsence_tr on ResourceAbsence (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandler.runTriggerByCustomMeta(this);
}