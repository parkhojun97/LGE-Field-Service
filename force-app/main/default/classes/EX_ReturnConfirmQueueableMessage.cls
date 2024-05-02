/**
 * @description       : 
 * @author            : hyungho.chun@dkbmc.com
 * @group             : 
 * @last modified on  : 09-09-2023
 * @last modified by  : hyungho.chun@dkbmc.com
**/
public with sharing class EX_ReturnConfirmQueueableMessage implements Queueable, Database.AllowsCallouts {

    private ReturnOrder ro;
    private List<EX_Message__c> msgList;

    public EX_ReturnConfirmQueueableMessage(ReturnOrder ro, List<EX_Message__c> msgList) {
        this.ro = ro;
        this.msgList = msgList;
    }

    public void execute(QueueableContext context) {

        List<String> exObjIdList = new List<String>();

        for (EX_Message__c msg : msgList) {
            exObjIdList.add(msg.Id);
        }
        
        System.debug('exObjIdList :: ' + exObjIdList);
        System.debug('ro :: ' + ro);

        for (String exObjId : exObjIdList) {
            if (!Test.isRunningTest()) {
                EX_ConsumablesOrderManagementController.doResend(exObjId, '주문 취소', '', String.valueOf(ro.CONSIGNEE_TPNO_1__c));
            }
        }        

    }
}