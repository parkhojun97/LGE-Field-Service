/**
 * Created by A78914 on 2023-04-25.
 */

trigger FN_SR_PAYMENT_BUNDLE_LINEITEM_Trigger on SR_PAYMENT_BUNDLE_LINEITEM__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
//    new FN_SrPaymentBundleLineitem_tr().run();
    // 2023-05-24 da.kim 동적 트리거핸들러 실행
    TriggerHandler.runTriggerByCustomMeta(this);
}