/**
 * Created by I2MAX.SEUNGHUNAN on 2023-03-07.
 */

@RestResource(UrlMapping='/v1/api/ma/heroku/SalesOrderConfirm')
global with sharing class EX_SaveSales {

    @HttpPost
    global static void doPost() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        Map<String, Object> reqBody = (Map<String, Object>)JSON.deserializeUntyped(request.requestBody.toString());
        Set<String> targetIdSet = new Set<String>();
        Set<String> orderNumberSet = new Set<String>();
        JSONGenerator jg = JSON.createGenerator(true);
        List<Object> targetIdList = (List<Object>)reqBody.get('target');

        for (Object o : targetIdList) {
            targetIdSet.add(o.toString());
        }

        // PRLI ? SR_ONLINE_DELIVERY_INFO__c?
        List<ProductRequestLineItem> targetPrLiList = [
                SELECT Id, Order_Number__c
                FROM ProductRequestLineItem
                WHERE Consumables_Order_YN__c = TRUE
                AND Parent.Consumables_Order_USE_YN__c = TRUE
                AND RecordType.DeveloperName='Consumable'
                AND SR_SALE__c = NULL
                AND SALE_Number__c = NULL
                AND Id IN:targetIdSet
        ];

        for (ProductRequestLineItem prLi : targetPrLiList) {
            orderNumberSet.add(prLi.Order_Number__c);
        }

        // 판매저장 메서드 호출
        Map<String, Object> rtnMap = EX_ConsumableUtil.doSaveSales(new List<String>(orderNumberSet));

        jg.writeStartObject();
        jg.writeObjectField('result', rtnMap);
        jg.writeEndObject();

        response.responseBody = Blob.valueOf(jg.getAsString());
    }
}