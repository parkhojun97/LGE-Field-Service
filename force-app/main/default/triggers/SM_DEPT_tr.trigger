/**
 * @description       : 
 * @author            : sangjae.Lee
 * @group             : 
 * @last modified on  : 10-20-2022
 * @last modified by  : sangjae.Lee
**/
trigger SM_DEPT_tr on SM_DEPT__c (before insert, before update, before delete, after insert, after update) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    /*
    SM_DEPT_trHandler triggerHandler = new SM_DEPT_trHandler();
    // triggerHandler.setMaxLoopCount(1);
    triggerHandler.run();
    */
}