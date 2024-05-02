/**
 * File Name    : FS_FileInformation.trigger
 * Author       : da.kim
 * Date         : 2023-07-27
 * Tester       : FS_FileInformation_tr_test.cls
 * Description  : 파일목록 트리거
 * Modification Log
 * ======================================================================================
 * Ver      Date            Author              Modification
 * ======================================================================================
 * 1.0      2023-07-27      da.kim              Create
**/
trigger FS_FileInformation on FS_FileInformation__c (before insert, before update, before delete, after insert, after update, after delete) {
    TriggerHandler.runTriggerByCustomMeta(this);
}