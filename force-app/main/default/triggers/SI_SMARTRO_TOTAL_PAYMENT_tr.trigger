/**
 * Created by I2MAX.JAEYEONLEE on 2023-03-24.
 */

trigger SI_SMARTRO_TOTAL_PAYMENT_tr on SI_SMARTRO_TOTAL_PAYMENT__c (before insert, before update, after insert, after update) {
   // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
   //new SI_SMARTRO_TOTAL_PAYMENT_trHandler().run();
}