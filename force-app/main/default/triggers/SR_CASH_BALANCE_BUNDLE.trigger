/**
 * Created by A78911 on 2023-03-07.
 */

trigger SR_CASH_BALANCE_BUNDLE on SR_CASH_BALANCE_BUNDLE__c (before update, after update) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new FN_SrCashBalanceBundle_tr().run();

}