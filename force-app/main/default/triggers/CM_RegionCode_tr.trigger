/******************************************************************
  * File Name   : CM_RegionCode_tr
  * Description : 
  * Author      : won.suh
  * Modification Log
  * ===============================================================
  * Ver  Date           Author          Modification
  * ===============================================================
    1.0  2024-02-08     won.suh         Create
******************************************************************/

trigger CM_RegionCode_tr on CM_RegionCode__c (before delete) {
    TriggerHandler.runTriggerByCustomMeta(this);
}