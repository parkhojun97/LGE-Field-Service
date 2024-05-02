/**
 * ==================================================================================
 * File Name         : ProductItem_tr
 * Author            : Changjoo.Sohn
 * Group             : Daeu Nextier
 * Description       : 
 * Modification Logs
 * ==================================================================================
 *   Ver     Date          Author          Modification
 * ==================================================================================
 *   1.0   2022-12-20     Changjoo.Sohn   Initial Version
**/
trigger ProductItem_tr on ProductItem (before insert, before update, after insert, after update, after delete, after undelete) {
//    new ProductItem_tr().run();
    // 2023-05-24 da.kim 동적 트리거핸들러 실행
    TriggerHandler.runTriggerByCustomMeta(this);
}