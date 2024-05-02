/**
 * Created by A78914 on 2023-01-04.
 */

trigger SR_DEPOSIT_REAPPLYING_BUNDLE_Trigger on SR_DEPOSIT_REAPPLYING_BUNDLE__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new FN_SrDepositReapplyingBundle_tr().run();
}