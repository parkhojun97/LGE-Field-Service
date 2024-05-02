/******************************************************************
  * File Name   : ServiceTerritory_tr
  * Description : 
  * Author      : won.suh
  * Modification Log
  * ===============================================================
  * Ver  Date           Author          Modification
  * ===============================================================
    1.0  2023-05-04     won.suh         Create
******************************************************************/

trigger ServiceTerritory_tr on ServiceTerritory (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
//    new ServiceTerritory_trHandler().run();
    // 2023-05-24 da.kim 동적 트리거핸들러 실행
    TriggerHandler.runTriggerByCustomMeta(this);
}