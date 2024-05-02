/**
 * Created by A78914 on 2023-04-25.
 */

trigger SR_PAYMENT_BUNDLE_Trigger on SR_PAYMENT_BUNDLE__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new FN_SrPaymentBundle_tr().run();
}