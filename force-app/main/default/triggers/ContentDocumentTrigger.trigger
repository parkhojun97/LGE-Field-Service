/**
 * Created by pttc on 12/2/22.
 */

trigger ContentDocumentTrigger on ContentDocument (before delete) {
//    new FN_ContentDocument_tr().run();
    // 2023-05-24 da.kim 동적 트리거핸들러 실행
    TriggerHandler.runTriggerByCustomMeta(this);
}