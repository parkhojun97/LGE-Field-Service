/**
 * @description       : 
 * @author            : sangjae.Lee
 * @group             : 
 * @last modified on  : 11-15-2022
 * @last modified by  : sangjae.Lee
**/
trigger Product2_tr on Product2 (before insert, before update) {
//    new Product2_trHandler().run();
    // 2023-05-24 da.kim 동적 트리거핸들러 실행
    TriggerHandler.runTriggerByCustomMeta(this);
}