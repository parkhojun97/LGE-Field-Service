/*
    테스트용도
*/
trigger ContactRequest_tr on ContactRequest (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
//    new ContactRequest_trHandler().run();
    // 2023-05-24 da.kim 동적 트리거핸들러 실행
    TriggerHandler.runTriggerByCustomMeta(this);
}