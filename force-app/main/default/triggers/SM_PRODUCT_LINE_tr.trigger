/**************************************************************************************** 
 * File Name    : SM_PRODDUCT_LINE.trigger
 * Author       : sangjae.lee
 * Date         : 2022-07-18
 * Tester       : SM_PRODDUCT_LINE_tr_Test.cls
 * Description  :
 * Modification Log
 * =============================================================== 
 * Ver      Date        Author              Modification
 * ===============================================================
   1.0      2022-07-18  sangjae.lee         Create
****************************************************************************************/
trigger SM_PRODUCT_LINE_tr on SM_PRODUCT_LINE__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
  // 2023-05-23 Trigger handler On/OFF 공통 대체
    TriggerHandler.runTriggerByCustomMeta(this);
    //new SM_PRODUCT_LINE_trHandler().run();
}