/**
 @ FileName      : SI_Counter_tr
 @ Created by    : mingi.chae
 @ Created Date  : 2023-09-22
 @ Description   : 
 */

trigger SI_Counter_tr on SI_Counter__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // Apex TriggerHandler 실행
    new SI_Counter_tr().run();
}