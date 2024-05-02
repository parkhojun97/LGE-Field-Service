/**
 * @description       : 
 * @author            : sangjae.Lee
 * @group             : 
 * @last modified on  : 11-23-2022
 * @last modified by  : sangjae.Lee
**/
trigger SM_CODE_tr on SM_CODE__c (before insert, before update, after insert, after update) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new SM_CODE_trHandler().run();
}