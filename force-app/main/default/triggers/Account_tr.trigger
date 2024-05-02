/**
 * @description       : 
 * @author            : dw.Lee
 * @group             : 
 * @last modified on  : 05-02-2023
 * @last modified by  : dw.Lee
**/
trigger Account_tr on Account (before insert, before update, after insert, after update, after delete) {
//    new Account_trHandler().run();
    // 2023-05-24 da.kim 동적 트리거핸들러 실행
    TriggerHandler.runTriggerByCustomMeta(this);
}