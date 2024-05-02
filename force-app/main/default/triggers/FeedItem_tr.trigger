/**
 * Created by A85093 on 2023-08-30.
 */

trigger FeedItem_tr on FeedItem (before insert, after insert) {
    TriggerHandler.runTriggerByCustomMeta(this);
}