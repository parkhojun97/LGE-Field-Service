/**
 * @description       : 
 * @author            : sangjae.Lee
 * @group             : 
 * @last modified on  : 09-07-2022
 * @last modified by  : sangjae.Lee
**/
trigger ContentVersion_tr on ContentVersion (before insert, after insert) {
//    System.debug('init before and after insert!');
//    new ContentVersion_trHandler().run();
//    new ContentVersion_trMCSHandler().run();
    // 2023-05-24 da.kim 동적 트리거핸들러 실행
    TriggerHandler.runTriggerByCustomMeta(this);
}