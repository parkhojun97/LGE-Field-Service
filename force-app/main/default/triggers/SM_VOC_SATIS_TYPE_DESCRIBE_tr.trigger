/**
 * @description       : 
 * @author            : sangjae.Lee
 * @group             : 
 * @last modified on  : 12-12-2022
 * @last modified by  : sangjae.Lee
**/
trigger SM_VOC_SATIS_TYPE_DESCRIBE_tr on SM_VOC_SATIS_TYPE_DESCRIBE__c (before insert, before update, after insert, after update) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new SM_VOC_SATIS_TYPE_DESCRIBE_trHandler().run();
}