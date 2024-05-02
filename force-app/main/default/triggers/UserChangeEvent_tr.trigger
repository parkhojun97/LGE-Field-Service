/**
 * Created by A85093 on 2023-09-07.
 */

trigger UserChangeEvent_tr on UserChangeEvent (after insert) {
    TriggerHandler.runTriggerByCustomMeta(this);
}