/**
 * Created by A80598 on 2023-04-20.
 */

trigger SI_GCSC_ORDERINFO_tr on SI_GCSC_ORDERINFO__c (after insert) {
    // 2023-05-23 Trigger handler On/OFF 공통 대체
	TriggerHandler.runTriggerByCustomMeta(this);
    //new SI_GCSC_ORDERINFO_tr().run();
}