/**
 * Created by A78911 on 2023-03-21.
 */

trigger SM_DIRECT_SVC_FEE on SM_DIRECT_SVC_FEE__c (before insert, before update) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new FN_SmDirectSvcFee_tr().run();

}