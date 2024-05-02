trigger ExchangeFileInformation_tr on ExchangeFileInformation__c (before insert, before update, after insert, after update) {
//    new FS_ExchangeFileInformation_tr().run();
    // 2023-05-24 da.kim 동적 트리거핸들러 실행
    TriggerHandler.runTriggerByCustomMeta(this);
}