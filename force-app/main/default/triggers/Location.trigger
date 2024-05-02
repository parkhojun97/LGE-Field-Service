/**
 * ==================================================================================
 * File Name         : Location
 * Author            : Changjoo.Sohn
 * Group             : Daeu Nextier
 * Description       : 
 * Modification Logs
 * ==================================================================================
 *   Ver     Date          Author          Modification
 * ==================================================================================
 *   1.0   2022-08-08     Changjoo.Sohn   Initial Version
**/
trigger Location on Location (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
//    new Location_tr().run();
    // 2023-05-24 da.kim 동적 트리거핸들러 실행
    TriggerHandler.runTriggerByCustomMeta(this);
}