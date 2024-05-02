/**
 * Created by I2MAX.SEOKHOLEE on 2023-05-20.
 */

trigger EX_Promotion_tr on EX_Promotion__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new EX_Promotion_tr().run();
}