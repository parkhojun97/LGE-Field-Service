/**
 * Created by I2MAX.SEUNGHUNAN on 2023-04-03.
 */

public with sharing class EX_CancelCashReceipt implements Queueable, Database.AllowsCallouts {
    private SR_PRE_PAYMENT_DETAIL__c aContext;
    private Payment_Gateway__c kPg;
    private Decimal aAmount;
    private ReturnOrder ro;
    private List<ReturnOrderLineItem> roLiList;


    public EX_CancelCashReceipt(SR_PRE_PAYMENT_DETAIL__c aContext, Payment_Gateway__c kPg, Decimal aAmount, ReturnOrder ro,List<ReturnOrderLineItem> roLiList) {
        this.aContext = aContext;
        this.kPg = kPg;
        this.aAmount = aAmount;
        this.ro = ro;
        this.roLiList = roLiList;
    }
    public void execute(QueueableContext ctx) {
        try {
            FN_PaymentModel.T_RES_CancelPayment res = (FN_PaymentModel.T_RES_CancelPayment) FNAPI.cancelCashReceiptApiPartial(aContext.TID_CASH__c, aContext.APPR_NUM__c, aAmount, kpg.MID__c, kpg.SIGN_KEY__c);
            if (res.message.equalsIgnoreCase('Success') || res.ErrorCode == '2013') {
                // 성공
                System.debug('현금영수증 취소 성공');
                //23 09 12 hyungho.chun 가상계좌 현금영수증 알림톡 따로 호출
                List<EX_Message__c> msgList = new List<EX_Message__c>();
                List<String> exObjIdList = new List<String>();

                for (ReturnOrderLineItem roliItem : roliList) {
                    EX_Message__c msg = new EX_Message__c();

                    msg.Label1__c = ro.CONSIGNEE_Name__c;
                    msg.Label2__c = ro.Order_Number__c;
                    msg.Label3__c = roliItem.ProductRequestLineItem.fm_Consumables_PART_DESC_KOR__c;
                    msgList.add(msg);
                }

                insert msgList;

                for (EX_Message__c msg : msgList) {
                    exObjIdList.add(msg.Id);
                }

                System.debug('exObjIdList :: ' + exObjIdList);

                if(!Test.isRunningTest()) System.enqueueJob(new EX_ReturnConfirmQueueableMessage(ro, msgList));                     

            } else {
                // todo: 오류 정보 저장
                // System.debug(res.ResultMsg);
                throw new FNException('현금영수증 취소 실패');
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
}