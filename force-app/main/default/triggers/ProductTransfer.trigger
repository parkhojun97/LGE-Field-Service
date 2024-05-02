trigger ProductTransfer on ProductTransfer (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
//    new ProductTransfer_tr().run();
    // 2023-05-24 da.kim 동적 트리거핸들러 실행
    TriggerHandler.runTriggerByCustomMeta(this);
}