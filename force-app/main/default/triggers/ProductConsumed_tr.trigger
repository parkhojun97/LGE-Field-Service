/**
 * @description       : 
 * @author            : eunseon.hwang
 * @last modified on  : 2023-07-25
 * @last modified by  : eunseon.hwang
**/
trigger ProductConsumed_tr on ProductConsumed (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandler.runTriggerByCustomMeta(this);
}