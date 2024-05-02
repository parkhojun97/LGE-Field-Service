/**
 * @description       : 
 * @author            : sangjae.Lee
 * @group             : 
 * @last modified on  : 11-23-2022
 * @last modified by  : sangjae.Lee
**/
trigger BadGoodsCollectType_tr on BadGoodsCollectType__c (before insert, before update, after insert, after update) {
//    new BadGoodsCollectType_trHandler().run();
    // 2023-05-24 da.kim 동적 트리거핸들러 실행
    TriggerHandler.runTriggerByCustomMeta(this);
}