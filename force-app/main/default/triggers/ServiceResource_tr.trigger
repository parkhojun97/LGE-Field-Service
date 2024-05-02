/**
 * Created by 85243 on 2022-11-24.
 */

trigger ServiceResource_tr on ServiceResource (before insert, before update, after insert, after update) {
//    new ServiceResource_trHandler().run();
    // 2023-05-24 da.kim 동적 트리거핸들러 실행
    TriggerHandler.runTriggerByCustomMeta(this);
}