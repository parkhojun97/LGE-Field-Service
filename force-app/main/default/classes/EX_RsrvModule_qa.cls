/**
 * Created by I2MAX.SEOKHOLEE on 2022-05-30.
 */

public without sharing class EX_RsrvModule_qa implements Queueable {
    List<Map<String, Object>> mapList;
    @TestVisible
    Set<String> failPrliIdSet;

    public EX_RsrvModule_qa() {

    }
    public EX_RsrvModule_qa(List<Map<String, Object>> mapList) {
        System.debug(' ========== EX_RsrvModule_qa ========== ');
        this.mapList = mapList;
    }

    @TestVisible
    public void execute(QueueableContext context) {
        Map<String, Object> returnMap;
        try {
            if(!Test.isRunningTest()) {
                returnMap = EX_RsrvUtil.RESRV_MODULE(mapList);
            }

            if(failPrliIdSet.isEmpty()) {
                failPrliIdSet = new Set<String>();
            }
            if(!Test.isRunningTest()) {
                for (String originPrliId : returnMap.keySet()) {
                    if (returnMap.get(originPrliId) == false) {
                        failPrliIdSet.add(originPrliId);
                    }
                }
            }
            if(failPrliIdSet.isEmpty()) return;
            List<ProductRequestLineItem> failPrliList = [
                    SELECT Id, Order_Number__c, Order_CHNL_TYPE_Code__c
                    FROM ProductRequestLineItem
                    WHERE Id IN :failPrliIdSet
            ];

            Map<String, SR_ONLINE_AUTO_SALE_EXC__c> insertTargetMaps = new Map<String, SR_ONLINE_AUTO_SALE_EXC__c>();
            SR_ONLINE_AUTO_SALE_EXC__c insertTarget;

            for (ProductRequestLineItem fPrli : failPrliList) {
                insertTarget = new SR_ONLINE_AUTO_SALE_EXC__c();
                insertTarget.ORDER_NO__c = fPrli.Order_Number__c;
                insertTarget.ORDER_CHANNEL__c = fPrli.Order_CHNL_TYPE_Code__c;
                insertTarget.ERROR_DATE__c = System.today();
                insertTarget.Input_date__c =  System.now();
                insertTarget.Last_update_date__c = System.now();
                insertTarget.SourceRecordId__c = fPrli.Id;
                insertTarget.ErrorType__c = 'Reserve';
                insertTargetMaps.put(insertTarget.SourceRecordId__c, insertTarget);
            }

            insert insertTargetMaps.values();

            if (!insertTargetMaps.isEmpty()) {
                EX_ConsumableUtil.doSendChatterFeed(insertTargetMaps.keySet());
            }



        } catch (Exception e) {
            System.debug(e.getLineNumber() + 'Line || ' + e.getMessage());
        }
    }

}