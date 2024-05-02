/**
 * @description       : 
 * @author            : KyeoRe.Lee
 * @group             : 
 * @last modified on  : 03-10-2023
 * @last modified by  : KyeoRe.Lee
**/

trigger User_tr on User (before insert, before update, after insert, after update) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new User_trHandler().run();
}