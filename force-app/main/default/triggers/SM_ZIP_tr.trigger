/**
 * @description       : 
 * @author            : KyeoRe.Lee
 * @group             : 
 * @last modified on  : 05-18-2023
 * @last modified by  : KyeoRe.Lee
**/
trigger SM_ZIP_tr on SM_ZIP__c (before insert, before update, after insert, after update) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    /*
    SM_ZIP_trHandler triggerHandler = new SM_ZIP_trHandler();
    triggerHandler.run();
    */
}