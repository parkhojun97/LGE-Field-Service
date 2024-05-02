/**
 * Created by I2MAX.SEUNGHUNAN on 2023-05-17.
 */

public with sharing class EX_ReturnConfirm_ba implements Database.Batchable<SObject>, Database.Stateful {
    public Map<String, Object> paramMap = new Map<String, Object>();
    public Iterable<SObject> start(Database.BatchableContext param1) {
        paramMap = EX_ConsumableUtil.preWorkReturnConfirm(null);
        List<ReturnOrder> roList = (List<ReturnOrder>)paramMap.get('roList');

        return roList;
    }
    public void execute(Database.BatchableContext param1, List<ReturnOrder> roList) {
        if(!Test.isRunningTest()) EX_ConsumableUtil.doReturnOrderConfirm2(paramMap, roList);
    }

    public void finish(Database.BatchableContext param1) {
        List<String> failOrderNumberList = (List<String>) paramMap.get('failOrderNumberList');
        List<ReturnOrder> roList = (List<ReturnOrder>) paramMap.get('roList');
        List<ReturnOrder> refundRoList = new List<ReturnOrder>();

        for (ReturnOrder ro : roList) {
            if (!failOrderNumberList.contains(ro.Order_Number__c)) {
                refundRoList.add(ro);
            }
        }

        // 23.06.18 환불처리 배치
        Database.executeBatch(new EX_Refund_ba(refundRoList, paramMap), 1);
    }
}