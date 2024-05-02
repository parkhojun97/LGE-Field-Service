/**
 * Created by A78914 on 2022-12-21.
 */

trigger SR_PAYMENT_BASIS on SR_PAYMENT_BASIS__c (before insert, after insert, before update) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new FN_SrPaymentBasis_tr().run();
}