/**
 * @description       : 
 * @author            : sangjae.Lee
 * @group             : 
 * @last modified on  : 11-21-2022
 * @last modified by  : sangjae.Lee
**/
trigger ContentDocument_tr on ContentDocument (before insert, after insert, before delete, after delete) {
//    new ContentDocument_trHandler().run();
    // 2023-05-24 da.kim 동적 트리거핸들러 실행
    TriggerHandler.runTriggerByCustomMeta(this);
}