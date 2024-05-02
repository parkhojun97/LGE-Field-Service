/**
 * Created by sm.yang on 2023-02-16.
 */

trigger Task_tr on Task (before insert, before update, after insert) {
	// 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
	//new Task_trHandler().run();
}