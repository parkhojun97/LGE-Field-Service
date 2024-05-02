trigger Exchange_External_File_tr on Exchange_External_File__e (after insert) {
//    new FS_ExchangeFileInformation_e_tr().run();
    // 2023-05-24 da.kim 동적 트리거핸들러 실행
    TriggerHandler.runTriggerByCustomMeta(this);
}