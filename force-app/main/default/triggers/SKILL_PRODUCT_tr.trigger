/******************************************************************
  * File Name   : SKILL_PRODUCT_tr
  * Description : SM 역량제품 생성/수정/삭제 시 Service Resource Skill에 반영
  * Author      : won.suh
  * Modification Log
  * ===============================================================ㄴ
  * Ver  Date           Author          Modification
  * ===============================================================
    1.0  2023-06-13     won.suh         Create
******************************************************************/

trigger SKILL_PRODUCT_tr on SKILL_PRODUCT__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandler.runTriggerByCustomMeta(this);
}